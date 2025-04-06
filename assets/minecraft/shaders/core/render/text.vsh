#version 150
#define VSH
#define RENDERTYPE_TEXT

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float GameTime;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 baseColor;
out vec4 lightColor;
out vec2 faceCoords;

// VideoPlayer START
flat out int isVideoDisplay;
flat out int videoWidth;
flat out int videoHeight;
flat out int videoX;
flat out int videoY;
// VideoPlayer END

// AnimatedEsc START
out vec2 coord;
flat out int isBanner;

out float applyGlint;
out float glintTime;
out float isConfetti;
// AnimatedEsc END

flat out int screenOverlayId;

#moj_import <lib/spheya/spheya_packs_impl.glsl>
#moj_import <lib/animated_esc/animated_esc_util.glsl>
#moj_import <lib/video_player/video_player_util.glsl>
#moj_import <lib/screen_overlay/screen_overlay.glsl>

void main() {
    applyGlint = 0.0;
    isConfetti = 0.0;
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    // Emissive START
    baseColor = Color;
    lightColor = texelFetch(Sampler2, UV2 / 16, 0);
    // Emissive END

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = baseColor * lightColor;
    texCoord0 = UV0;
    faceCoords = vec2[](vec2(-1.0, 1.0), vec2(-1.0, -1.0), vec2(1.0, -1.0), vec2(1.0, 1.0))[gl_VertexID % 4];

    screenOverlayId = getScreenOverlayId(texture(Sampler0, texCoord0));
    if(screenOverlayId != SCREEN_OVERLAY_ID_NONE)
        gl_Position = vec4(faceCoords, 0.0, 1.0);

    // Spheya START
    if (applySpheyaPacks()) return;
    // Spheya END

    // Objective START
    if (Position.y < -1024.0 && length(Position.xz) <= 0.1) {
        float scaleFactor = 1024.0;
        float aspect = ScreenSize.x / ScreenSize.y;
        vec2 pos = Position.xy;
        vec2 anchor;
        if (Position.y < -2048.0) {
            pos.y += 2048.0 + 512.0f;
            anchor = vec2(1.0, 0.0);
        } else {
            pos.y += 1024.0 + 512.0f;
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
        return;
    }
    // Objective END

    // VideoPlayer START
    make_video_player();
    // VideoPlayer END

    // AnimatedEsc START
    make_animated_escape();
    // AnimatedEsc END
}
