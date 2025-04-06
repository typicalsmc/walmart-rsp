#version 150
#define VSH

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;
uniform sampler2D Sampler0;

uniform float FogStart;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 TextureMat;
uniform int FogShape;
uniform vec2 ScreenSize;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec4 faceLightColor;
out vec4 overlayColor;
out vec4 lightColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 tintColor;
flat out int isGUI;
flat out ivec3 coordinateData;
#ifdef ENTITY_TRANSLUCENT
out float part;
flat out int quadId;
flat out int isFpa;
flat out int isAvatar;
#endif
flat out int is2D;

#moj_import <lib/coordinate_data.glsl>
#moj_import <lib/2d/2d_utils.glsl>

#define SPACING 1024.0
#define MAX_RANGE (0.5 * SPACING)
#define SKIN_SIZE 64
#define FACE_SIZE 8
#define FOV 40.0

const vec4[] subUVs = vec4[](
    vec4(4.0,  0.0,  8.0,  4.0 ), // 4x4x12
    vec4(8.0,  0.0,  12.0, 4.0 ),
    vec4(0.0,  4.0,  4.0,  16.0),
    vec4(4.0,  4.0,  8.0,  16.0),
    vec4(8.0,  4.0,  12.0, 16.0), 
    vec4(12.0, 4.0,  16.0, 16.0), 
    vec4(4.0,  0.0,  7.0,  4.0 ), // 4x3x12
    vec4(7.0,  0.0,  10.0, 4.0 ),
    vec4(0.0,  4.0,  4.0,  16.0),
    vec4(4.0,  4.0,  7.0,  16.0),
    vec4(7.0,  4.0,  11.0, 16.0), 
    vec4(11.0, 4.0,  14.0, 16.0),
    vec4(4.0,  0.0,  12.0, 4.0 ), // 4x8x12
    vec4(12.0,  0.0, 20.0, 4.0 ),
    vec4(0.0,  4.0,  4.0,  16.0),
    vec4(4.0,  4.0,  12.0, 16.0),
    vec4(12.0, 4.0,  16.0, 16.0),
    vec4(16.0, 4.0,  24.0, 16.0)
);

const vec2[] origins = vec2[](
    vec2(40.0, 16.0), // right arm
    vec2(40.0, 32.0),
    vec2(32.0, 48.0), // left arm
    vec2(48.0, 48.0),
    vec2(16.0, 16.0), // torso
    vec2(16.0, 32.0),
    vec2(0.0,  16.0), // right leg
    vec2(0.0,  32.0),
    vec2(16.0, 48.0), // left leg
    vec2(0.0,  48.0)
);

const int[] faceRemap = int[](0, 0, 1, 1, 2, 3, 4, 5);

const float invTanHF = 1.0 / tan(radians(FOV / 2.0));

mat3 rotationMatrix(vec3 a, float angle) {
    a = normalize(a);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(
        oc * a.x * a.x + c,       oc * a.x * a.y - a.z * s, oc * a.z * a.x + a.y * s,
        oc * a.x * a.y + a.z * s, oc * a.y * a.y + c,       oc * a.y * a.z - a.x * s,
        oc * a.z * a.x - a.y * s, oc * a.y * a.z + a.x * s, oc * a.z * a.z + c
    );
}

mat4 changeFov(mat4 projection) {
    if (projection[2][3] != 0.0) {
        float aspectInv = projection[0][0] / projection[1][1];
        projection[0][0] = invTanHF * aspectInv;
        projection[1][1] = invTanHF;
    }
    return projection;
}

void main() {
    is2D = 0;
    tintColor = Color;
    isGUI = int(FogStart > 1e32);
#ifdef ENTITY_TRANSLUCENT
    quadId = 0;
    part = 0.0;
    isFpa = 0;
    isAvatar = 0;
#endif
    mat4 projMat = ProjMat;
    mat4 viewMat = ModelViewMat;
    vec3 worldPos = Position;
    coordinateData = extractCoordinateData(worldPos, bool(isGUI));

    vertexDistance = fog_distance(worldPos, FogShape);
#ifdef NO_CARDINAL_LIGHTING
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif
    faceLightColor = texelFetch(Sampler2, UV2 / 16, 0);
    lightColor = minecraft_sample_lightmap(Sampler2, UV2);
    overlayColor = texelFetch(Sampler1, UV1, 0);

    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif

    // 2D START
    if (GameTime > 0.5 && make_2d_world(projMat, viewMat, worldPos, isGUI, coordinateData, is2D)) {
        return;
    }
    // 2D END

#ifdef ENTITY_TRANSLUCENT
    ivec2 texSize = textureSize(Sampler0, 0);
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    if (
        ProjMat[2][3] != 0.0 &&
        texSize.x == SKIN_SIZE &&
        texSize.y == SKIN_SIZE &&
        Position.y < -8192.0 &&
        length(Position.xz) <= 0.1
    ) {
        if ((gl_VertexID / 24) % 2 == 1) {
            gl_Position = vec4(-10.0, -10.0, 0.0, 0.0);
            return;
        }

        float scaleFactor = 1024.0;
        float aspect = ScreenSize.x / ScreenSize.y;
        vec2 pos = Position.xy;
        vec2 anchor;
        if (Position.y < -9216.0) {
            pos.y += 9216.0 + 512.0f;
            anchor = vec2(1.0, 0.0);
        } else {
            pos.y += 8192.0 + 512.0f;
            anchor = vec2(-1.0, 1.0);
        }
        pos.y /= scaleFactor;
        pos.x *= scaleFactor;
        pos *= 2000.0;
        pos = vec2((pos.x / ScreenSize.x) * 2.0, (pos.y / ScreenSize.y) * 2.0);
        pos += anchor;
        gl_Position = vec4(pos, Position.z - 0.999, 1.0);
        vertexColor = Color;
        vertexDistance = 0.0;

        isAvatar = 1;
        quadId = (gl_VertexID / 4) % 24;
        const vec2 uvs[] = vec2[](vec2(1, 0), vec2(0, 0), vec2(0, 1), vec2(1, 1));
        texCoord0 = uvs[gl_VertexID % 4];

        return;
    }

    if (ProjMat[2][3] != 0.0 && texSize.x == SKIN_SIZE && texSize.y == SKIN_SIZE) {
        isFpa = 1;

        vec3 pos = Position / 1024.0f;
        vec2 uvOut = UV0;
        vec2 uvOut2 = vec2(0.0);
        int partID = -int((pos.y - MAX_RANGE) / SPACING) - 1;
        part = float(partID);

        if (partID == -1) {
            return;
        }

        mat4 projMat = changeFov(ProjMat);

        pos.y += SPACING * (partID + 1);

        // Offset
        pos += vec3(-0.1, -1.65, -1.4);

        gl_Position = projMat * vec4(pos, 1.0);
        gl_Position.z *= 0.001;
        vertexDistance = fog_distance(pos, FogShape);

        if (partID == 0) {
            return;
        }

        vec4 samp1 = texture(Sampler0, vec2(54.0 / 64.0, 20.0 / 64.0));
        vec4 samp2 = texture(Sampler0, vec2(55.0 / 64.0, 20.0 / 64.0));
        bool isSlim = samp1.a == 0.0 || (((samp1.r + samp1.g + samp1.b) == 0.0) && ((samp2.r + samp2.g + samp2.b) == 0.0) && samp1.a == 1.0 && samp2.a == 1.0);
        int outerLayer = (gl_VertexID / 24) % 2; 
        int vertexID = gl_VertexID % 4;
        int faceID = (gl_VertexID % 24) / 4;
        ivec2 faceIDTmp = ivec2(round(UV0 * SKIN_SIZE));
        if ((faceID != 1 && vertexID >= 2) || (faceID == 1 && vertexID <= 1)) {
            faceIDTmp.y -= FACE_SIZE;
        }
        if (vertexID == 0 || vertexID == 3) {
            faceIDTmp.x -= FACE_SIZE;
        }
        faceIDTmp /= FACE_SIZE;
        faceID = (faceIDTmp.x % 4) + 4 * faceIDTmp.y;
        faceID = faceRemap[faceID];
        int subUVIdx = faceID;

        uvOut = origins[2 * (partID - 1) + outerLayer];
        uvOut2 = origins[2 * (partID - 1)];

        if (isSlim && (partID == 1 || partID == 2)) {
            subUVIdx += 6;
        } else if (partID == 3) {
            subUVIdx += 12;
        }

        vec4 subUV = subUVs[subUVIdx];
        vec2 offset = vec2(0.0);
        if (faceID == 1) {
            if (vertexID == 0) {
                offset += subUV.zw;
            } else if (vertexID == 1) {
                offset += subUV.xw;
            } else if (vertexID == 2) {
                offset += subUV.xy;
            } else {
                offset += subUV.zy;
            }
        } else {
            if (vertexID == 0) {
                offset += subUV.zy;
            } else if (vertexID == 1) {
                offset += subUV.xy;
            } else if (vertexID == 2) {
                offset += subUV.xw;
            } else {
                offset += subUV.zw;
            }
        }

        uvOut += offset;
        uvOut2 += offset;
        uvOut /= float(SKIN_SIZE);
        uvOut2 /= float(SKIN_SIZE);
        texCoord0 = uvOut;
        texCoord1 = uvOut2;

        return;
    }
#endif

    gl_Position = projMat * viewMat * vec4(worldPos, 1.0);
}