#version 150
#define VSH

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform float FogStart;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;
uniform vec2 ScreenSize;
uniform float GameTime;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
flat out int isGUI;
out vec4 lightColor;
out vec4 faceLightColor;
flat out ivec3 coordinateData;
out vec4 normal;
flat out int isHighlighted;
flat out int isVideo;
flat out int videoFrameCount;
flat out int videoInitialFrame;
flat out int videoFlags;
out vec4 tintColor;
flat out int is2D;

#moj_import <lib/coordinate_data.glsl>
#moj_import <lib/skybox/skybox_utils.glsl>
#moj_import <lib/waypoint/waypoint_utils.glsl>
#moj_import <lib/2d/2d_utils.glsl>

#define FOV 40.0
#define CUSTOM_VIDEO_COLORS 255

const float invTanHF = 1.0 / tan(radians(FOV / 2.0));

mat4 changeFov(mat4 projection) {
    if (projection[2][3] != 0.0) {
        float aspectInv = projection[0][0] / projection[1][1];
        projection[0][0] = invTanHF * aspectInv;
        projection[1][1] = invTanHF;
    }
    return projection;
}

int pixelToInt(ivec4 pixel) {
    return pixel.r | (pixel.g << 8) | (pixel.b << 16);
}

void main() {
    is2D = 0;
    isVideo = 0;
    videoFrameCount = 0;
    videoInitialFrame = 0;
    videoFlags = 0;
    tintColor = Color;
    isGUI = int(FogStart > 1e32);
    mat4 projMat = ProjMat;
    mat4 viewMat = ModelViewMat;
    vec3 worldPos = Position;
    coordinateData = extractCoordinateData(worldPos, bool(isGUI));
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    isHighlighted = 0;
    if (Color.rgb == vec3(0xAB, 0xCD, 0xEF) / 0xFF) {
        isHighlighted = 1;
    } else if (Color.rgb == vec3(0xFE, 0xDC, 0xBA) / 0xFF) {
        isHighlighted = 2;
    } else if (Color.rgb == vec3(0x00, 0xFE, 0xED) / 0xFF) {
        isHighlighted = 3;
    }
    
    vertexDistance = fog_distance(worldPos, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, isHighlighted != 0 ? vec4(1.0) : Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;

    // Emissives START
    lightColor = minecraft_sample_lightmap(Sampler2, UV2);
    faceLightColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0));
    // Emissives END


#ifdef ITEM_ENTITY_TRANSLUCENT_CULL
    // Skybox START
    if (make_skybox()) {
        return;
    }
    // Skybox END

    // Video player START
    // if (abs(Position.y - 2024) < 0.1) {
    if (tintColor.rgb == vec3(0x00, 0xBE, 0xEF) / 0xFF) {
    // if (coordinateData.y < 0) {
        isVideo = 1;
        // Get video metadata
        ivec2 offset = ivec2(UV0 * textureSize(Sampler0, 0));
        offset.x += CUSTOM_VIDEO_COLORS;
        videoFrameCount   = pixelToInt(ivec4(texelFetch(Sampler0, offset + ivec2(0, 0), 0) * 255.0));
        videoInitialFrame = pixelToInt(ivec4(texelFetch(Sampler0, offset + ivec2(1, 0), 0) * 255.0));
        videoFlags        = pixelToInt(ivec4(texelFetch(Sampler0, offset + ivec2(2, 0), 0) * 255.0));
        // Set vertices to screen corners
        vec2 faceCoords = vec2[](vec2(0.0, 0.0), vec2(0.0, 1.0), vec2(1.0, 1.0), vec2(1.0, 0.0))[gl_VertexID % 4];
        texCoord1 = faceCoords;
        gl_Position = vec4(faceCoords.x * 2.0 - 1.0, (1.0 - faceCoords.y) * 2.0 - 1.0, -1.0, 1.0);
        return;
    }
    // Video player STOP
#endif

#ifdef ITEM_ENTITY_TRANSLUCENT_CULL
    // First person animations START
    vec3 pos = Position / 1024.0;
    if (pos.y < -1024.0) {
        mat4 projMat = changeFov(ProjMat);
        pos.y += 2048.0;
        // Offset
        pos += vec3(-0.1, -1.65, -1.4);
        gl_Position = projMat * vec4(pos, 1.0);
        gl_Position.z *= 0.001;
        vertexDistance = 0.0;
        return;
    }
    // First person animations END

    // Waypoint START
    if (make_waypoint()) {
        return;
    }
    // Waypoint END
#endif

    // 2D START
    if (make_2d_world(projMat, viewMat, worldPos, isGUI, coordinateData, is2D)) {
        return;
    }
    // 2D END

    gl_Position = projMat * viewMat * vec4(worldPos, 1.0);
}