#version 150

#define SCREEN_OVERLAY_ID_NONE 0
#define SCREEN_OVERLAY_ID_SHIELD 1
#define SCREEN_OVERLAY_ID_SPEED 2
#define SCREEN_OVERLAY_ID_DREAM 3

int getScreenOverlayId(vec4 color) {
    ivec4 col = ivec4(color * 255.5);
    if(col == ivec4(93, 107, 54, 255)) return SCREEN_OVERLAY_ID_SHIELD;
    if(col == ivec4(94, 107, 54, 255)) return SCREEN_OVERLAY_ID_SPEED;
    if(col == ivec4(95, 107, 54, 255)) return SCREEN_OVERLAY_ID_DREAM;
    return SCREEN_OVERLAY_ID_NONE;
}

vec4 screenOverlay(int id, vec2 uv) {
    const int particleCount = 64;
    vec4 color = vec4(0.0);
    float particleSpeed = 0.0;
    float particleDuration = 1.0;
    
    switch(id) {
        case SCREEN_OVERLAY_ID_SHIELD: color = vec4(0.00, 0.75, 1.00, 0.50); particleSpeed =  0.0; particleDuration = 1.0; break;
        case SCREEN_OVERLAY_ID_SPEED:  color = vec4(0.75, 1.00, 0.00, 0.50); particleSpeed = +4.0; particleDuration = 0.5; break;
        case SCREEN_OVERLAY_ID_DREAM:  color = vec4(1.00, 0.50, 0.80, 0.75); particleSpeed = -0.2; particleDuration = 1.0; break;
    }

    float t = max(dot(uv, uv) - 0.3, 0.0);
    vec4 backgroundColor =  color * vec4(1.0, 1.0, 1.0, t);
    vec4 overlayColor = vec4(3.0, 3.0, 3.0, 0.0);

    for(int i = 0; i < particleCount; ++i) {
        float aspect = (ScreenSize.x / ScreenSize.y);
        vec2 pos = uv * vec2(aspect, 1.0);
        float x = (random(i + 1000.0) * 2.0 - 1.0) * aspect;
        float y = random(i + 2000.0) * 2.0 - 1.0;
        vec2 particlePos = vec2(x, y);
        float s = random(i + 3000.0) * 0.002 + 0.0002;
        float time = mod(GameTime * 600.0 * particleDuration + random(i + 4000.0), 1.0);
        particlePos *= 1.0 + (particleSpeed * time);
        float a = -cos(time * TAU) * 0.5 + 0.5;
        if(dot(particlePos - pos, particlePos - pos) < s) {
            overlayColor.a += 0.2 * t * t * a;
        }
    }

    return vec4(mix(backgroundColor.rgb, overlayColor.rgb, overlayColor.a), 1.0 - (1.0 - backgroundColor.a) * (1.0 - overlayColor.a));
}