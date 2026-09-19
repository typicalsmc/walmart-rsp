#version 330

#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in vec4 vertexColor;
in vec2 texCoord0;
flat in int waypointDistanceText;

out vec4 fragColor;

void main() {
    vec4 texColor = texture(Sampler0, texCoord0);
    vec4 color;

    if (waypointDistanceText == 1) {
        color = vec4(vec3(1.0), texColor.a * vertexColor.a) * ColorModulator;
    } else {
        color = texColor * vertexColor * ColorModulator;
    }

    if (color.a < 0.1) {
        discard;
    }

    fragColor = color;
}
