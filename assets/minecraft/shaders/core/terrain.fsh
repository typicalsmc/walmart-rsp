#version 150
#define FSH

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 lightColor;
in vec4 faceLightColor;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    // Emissive
    vec4 pureColor = textureLod(Sampler0, texCoord0, 0.0);
    int alpha = int(round(pureColor.a * 255.0));
	if (alpha == 252) {
		color = vec4(pureColor.rgb, 1.0);
	}

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}