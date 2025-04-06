#version 140
#define FSH

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform int FogShape;
uniform mat4 ProjMat;
uniform vec2 ScreenSize;

uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec2 texCoord2;
flat in int isGUI;
in vec4 lightColor;
in vec4 faceLightColor;
flat in ivec3 coordinateData;
in vec4 normal;
flat in int isHighlighted;
flat in int isVideo;
flat in int videoFrameCount;
flat in int videoInitialFrame;
flat in int videoFlags;
in vec4 tintColor;
flat in int is2D;

out vec4 fragColor;

#moj_import <lib/dynamic_emissive/emissive_utils.glsl>
#moj_import <lib/2d/2d_utils.glsl>

#define CUSTOM_VIDEO_COLORS 255
#define CUSTOM_VIDEO_WIDTH 852
#define CUSTOM_VIDEO_HEIGHT 480
#define CUSTOM_VIDEO_TEX_WIDTH 8192

vec4 scan(vec4 rgb, vec2 uv, bool isScanning) {
    rgb.rgb = mix(rgb.rgb, vec3(0.0, isScanning ? 0.5 : 0.75, 1.0), 0.5);
    float x = 0.0;
    if (fract(0.125 * (uv.x + GameTime * 3000)) > 0.5) {
        x += 0.2;
    }
    if (!isScanning && fract(0.25 * (uv.x + GameTime * 12000)) > 0.5) {
        x *= (sin(0.1 * uv.x + GameTime * 4000) * 0.5 + 0.5);
        x += 0.1 * (sin(0.1 * uv.x + GameTime * 4000) * 0.5 + 0.5);
    }
    rgb.rgb += (sin(GameTime * 4000) * 0.5 + 0.5) * 0.25;
    rgb.rgb += x;
    return rgb;
}

vec4 highlight(vec4 rgb, vec2 uv, int variant) {
    if (variant == 3) {
        rgb.rgb = mix(rgb.rgb, vec3(1.0), 0.5 * (0.5 * sin(0.25 * GameTime * 24000.0) + 0.5));
        return rgb;
    } else {
        return scan(rgb, uv, variant == 1);
    }
}

void main() {
    if (isVideo == 1) {
        // black background
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);

        // video timing
        int time = int(GameTime * 24000);
        time -= videoInitialFrame;

        if (time >= 0) {
            bool cont = true;
            if (time >= videoFrameCount) {
                if ((videoFlags & 1) == 0) {
                    // return;
                    cont = false;
                } else {
                    time = videoFrameCount - 1;
                }
            }

            if (cont) {
                // maintain video aspect ratio
                vec2 videoUV = texCoord1;
                float aspect = float(CUSTOM_VIDEO_WIDTH) / float(CUSTOM_VIDEO_HEIGHT);
                float screenAspect = ScreenSize.x / ScreenSize.y;
                bool cont = true;
                if (aspect > screenAspect) {
                    float height = 1.0 / aspect;
                    float screenHeight = 1.0 / screenAspect;
                    float ratio = height / screenHeight;
                    videoUV.y = (videoUV.y - ((1.0 - ratio) / 2.0)) / ratio;
                    if (videoUV.y < 0 || videoUV.y > 1) {
                        cont = false;
                        // return;
                    }
                } else {
                    float width = aspect;
                    float screenWidth = screenAspect;
                    float ratio = width / screenWidth;
                    videoUV.x = (videoUV.x - ((1.0 - ratio) / 2.0)) / ratio;
                    if (videoUV.x < 0 || videoUV.x > 1) {
                        cont = false;
                        // return;
                    }
                }

                if (cont) {
                    ivec2 coords = ivec2(floor(videoUV.x * CUSTOM_VIDEO_WIDTH), floor(videoUV.y * CUSTOM_VIDEO_HEIGHT));
                    int byteIndex = coords.x + coords.y * CUSTOM_VIDEO_WIDTH;
                    int pixelIndex = byteIndex / 4;
                    int frameIndex = time;
                    int finalPixelIndex = CUSTOM_VIDEO_COLORS + 1 + 1 + 1 + frameIndex * (CUSTOM_VIDEO_WIDTH * CUSTOM_VIDEO_HEIGHT / 4) + pixelIndex;
                    ivec2 offset = ivec2(texCoord0 * textureSize(Sampler0, 0));

                    ivec4 x = ivec4(texelFetch(Sampler0, offset + ivec2(finalPixelIndex % CUSTOM_VIDEO_TEX_WIDTH, finalPixelIndex / CUSTOM_VIDEO_TEX_WIDTH), 0) * 255.0);
                    int paletteIndex;
                    int byteOffset = byteIndex % 4;
                    if (byteOffset == 0) paletteIndex = x.r;
                    else if (byteOffset == 1) paletteIndex = x.g;
                    else if (byteOffset == 2) paletteIndex = x.b;
                    else paletteIndex = x.a;

                    vec3 color = texelFetch(Sampler0, offset + ivec2(paletteIndex - 1, 0), 0).rgb;
                    fragColor = vec4(color, 1.0);
                }
            }
        }
    } else {
        // Emissives START
        vec4 pureColor = textureLod(Sampler0, texCoord0, 0.0);
        vec4 color = pureColor * vertexColor * ColorModulator;
        make_emissive(color, pureColor, tintColor);
        // Emissives END

        if (isHighlighted != 0) {
            vec2 dim = vec2(textureSize(Sampler0, 0));
            vec2 uv = texCoord0 * dim;
            color = highlight(color, uv, isHighlighted);
        }

        // 2D START
        make_2d_world_tint(color, tintColor);
        // 2D END

        if (color.a < 0.1) discard;
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    }

}
