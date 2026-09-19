#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;

bool is_waypoint(sampler2D tex, ivec2 pixel) {
    return ivec4(texelFetch(tex, pixel, 0) * 255.5) == ivec4(157, 211, 147, 99);
}

vec4 build_waypoint(inout vec2 texCoord, ivec2 texSize, vec2 size, vec3 position, vec2 faceCoords) {
    vec2 screenBounds = vec2(1.0) - size;

    ivec2 sprite = ivec2(0);
    vec4 center = ModelViewMat * vec4(position - vec3(faceCoords, 0.0), 1.0);
    vec4 clipPos = ProjMat * center;
    vec2 screenPos = clipPos.xy / clipPos.w;

    if (clipPos.z < 0.0 || abs(screenPos.x) > screenBounds.x || abs(screenPos.y) > screenBounds.y) {
        if (center.z >= 0.0) {
            screenPos *= -1.0;
        }

        vec2 t = screenBounds / abs(screenPos);
        screenPos *= min(t.x, t.y);
        sprite = ivec2(ivec2(2, -2) * screenPos);
    }

    vec2 uv = faceCoords + 0.5;
    uv.y = 1.0 - uv.y;
    uv = 33.0 + 30.0 * uv + 32.0 * sprite;
    texCoord += uv / vec2(texSize);

    return vec4(screenPos + size * faceCoords, -1.0, 1.0);
}

bool make_waypoint() {
    ivec2 texSize = textureSize(Sampler0, 0);
    ivec2 pixel = ivec2(UV0 * texSize);

    if (!is_waypoint(Sampler0, pixel)) {
        return false;
    }

    vec2 faceCoords = vec2[](
        vec2(-1.0, 1.0),
        vec2(-1.0, -1.0),
        vec2(1.0, -1.0),
        vec2(1.0, 1.0)
    )[gl_VertexID % 4];
    vec2 aspect = vec2(ScreenSize.x / ScreenSize.y, 1.0);
    vec2 scaleFactor = clamp(max((100.0 - length(Position)), 0.0) / 100.0, 0.75, 1.0) * vec2(0.25);

    gl_Position = build_waypoint(texCoord0, texSize, scaleFactor / aspect, Position, 0.5 * faceCoords);

    sphericalVertexDistance = 0.0;
    cylindricalVertexDistance = 0.0;
    vertexColor = vec4(1.0);
    texCoord1 = UV1;
    texCoord2 = UV2;

    return true;
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;

    make_waypoint();
}
