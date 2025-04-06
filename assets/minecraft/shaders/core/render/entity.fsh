#version 150
#define FSH

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform int FogShape;
uniform mat4 ProjMat;

uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec4 faceLightColor;
in vec4 lightColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 tintColor;
flat in int isGUI;
flat in ivec3 coordinateData;
#ifdef ENTITY_TRANSLUCENT
in float part;
flat in int quadId;
flat in int isFpa;
flat in int isAvatar;
#endif
in vec2 texCoord1;
flat in int is2D;

out vec4 fragColor;

#moj_import <lib/dynamic_emissive/emissive_utils.glsl>
#moj_import <lib/2d/2d_utils.glsl>
#moj_import <lib/avatar.glsl>

void main() {
    vec4 pureColor = texture(Sampler0, texCoord0);
    vec4 color = pureColor;

#ifdef ENTITY_TRANSLUCENT
    if (is2D != 1 && isAvatar == 1) {
        if (quadId != 3) discard;

        ivec2 pixelReset = ivec2(round(texCoord0 * 37.0 - 0.5));
        if (pixelReset.y >= 32) discard;
        fragColor = renderAvatar(pixelReset);

        if (fragColor.a < 0.1) discard;
        fragColor.a = 1.0;
        return;
    }

    if (color.a < 0.1 || abs(mod(part + 0.5, 1.0) - 0.5) > 0.001) {
        discard;
    }

    if (color.a < 1.0 && part > 0.5) {
        vec4 color2 = texture(Sampler0, texCoord1);
        if (color.a < 0.75 && int(gl_FragCoord.x + gl_FragCoord.y) % 2 == 0) {
            discard;
        }
        else {
            color.rgb = mix(color2.rgb, color.rgb, min(1.0, color.a * 2));
            color.a = 1.0;
        }
    }

    // 2D START
    if (is2D == 1) make_2d_player(color, coordinateData);
    // 2D END
#endif

#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    color *= vertexColor * ColorModulator;

    // Emissives START
    make_emissive(color, pureColor, tintColor);
    // Emissives END

#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= faceLightColor;
#endif
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
