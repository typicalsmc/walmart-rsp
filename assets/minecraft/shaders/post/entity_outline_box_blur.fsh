#version 150

uniform sampler2D InSampler;
uniform float GameTime;

in vec2 texCoord;
in vec2 sampleStep;

out vec4 fragColor;

void main() {
    // Highlights
    vec4 texSample = texture(InSampler, texCoord);
    if(texSample.a > 0.0) {
        fragColor = texSample;
        return;
    }

    // Outline
    float radius = 1.5 + (sin(GameTime * 12000.0) * 1.5 + 1.5);
    for (float x = -radius; x <= radius; x += 1.0) {
        for (float y = -radius; y <= radius; y += 1.0) {
            vec2 offset = vec2(x, y) * sampleStep;
            vec4 surroundingSample = texture(InSampler, texCoord + offset);
            if (surroundingSample.a > 0.0) {
                fragColor = vec4(1.0);
                return;
            }
        }
    }

    fragColor = vec4(0.0);
}
