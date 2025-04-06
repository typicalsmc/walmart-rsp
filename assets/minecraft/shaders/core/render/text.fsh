#version 150
#define FSH
#define RENDERTYPE_TEXT

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;
uniform vec2 ScreenSize;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 baseColor;
in vec4 lightColor;
in vec2 faceCoords;

// VideoPlayer START
flat in int isVideoDisplay;
flat in int videoWidth;
flat in int videoHeight;
flat in int videoX;
flat in int videoY;
// VideoPlayer END

// AnimatedEsc START
in vec2 coord;
flat in int isBanner;

in float applyGlint;
in float glintTime;
in float isConfetti;
// AnimatedEsc END

flat in int screenOverlayId;

out vec4 fragColor;

#moj_import <lib/spheya/spheya_packs_impl.glsl>
#moj_import <lib/animated_esc/animated_esc_util.glsl>
#moj_import <lib/video_player/video_player_util.glsl>
#moj_import <lib/screen_overlay/screen_overlay.glsl>

void main() {
    if(applySpheyaPacks()) return;

    // VideoPlayer START
    make_video_player();
    // VideoPlayer END

    if(screenOverlayId != SCREEN_OVERLAY_ID_NONE) {
        fragColor = screenOverlay(screenOverlayId, faceCoords);
        if(fragColor.a <= 0.0) discard;
        return;
    }

    // AnimatedEsc START
    // vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    vec4 color;
    make_animated_escape(color);
    // AnimatedEsc END
    
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
