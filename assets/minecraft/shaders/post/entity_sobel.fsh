#version 150

uniform sampler2D InSampler;
uniform float GameTime;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

void main(){
    // Highlights
    vec4 texSample = texture(InSampler, texCoord);
    if(texSample.a > 0.0) {
        float t = (gl_FragCoord.x + gl_FragCoord.y + GameTime * 24000.0) / 16.0;
        float alpha = (sin(GameTime * 3600.0) * 0.5 + 0.5) + 0.01;
        fragColor = vec4(texSample.rgb, (fract(t) < 0.5 ? 0.40 : 0.55) * alpha);
        return;
    }

    // Vanilla shader
    vec4 center = texSample;
    vec4 left = texture(InSampler, texCoord - vec2(oneTexel.x, 0.0));
    vec4 right = texture(InSampler, texCoord + vec2(oneTexel.x, 0.0));
    vec4 up = texture(InSampler, texCoord - vec2(0.0, oneTexel.y));
    vec4 down = texture(InSampler, texCoord + vec2(0.0, oneTexel.y));
    float leftDiff  = abs(center.a - left.a);
    float rightDiff = abs(center.a - right.a);
    float upDiff    = abs(center.a - up.a);
    float downDiff  = abs(center.a - down.a);
    float total = clamp(leftDiff + rightDiff + upDiff + downDiff, 0.0, 1.0);
    vec3 outColor = center.rgb * center.a + left.rgb * left.a + right.rgb * right.a + up.rgb * up.a + down.rgb * down.a;
    fragColor = vec4(outColor * 0.2, total);
}
