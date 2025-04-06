#version 150

#define FRAMES 35.0
#define DURATION 3.5

const vec2[] corners = vec2[](
    vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0)
);

#ifdef RENDERTYPE_TEXT
#ifdef VSH
bool make_animated_escape() {
    if (Color.xyz == vec3(0.0, 0.0, 0xAA) / 0xFF || Color.xyz == vec3(0.0, 0.0, 0x2A) / 0xFF) {
        if (ProjMat[3][3] != 0.0 && fract(Position.z) < 0.01 && Position.z != 2000.0) {
            vertexColor *= 0.0;
        } else {
            isBanner = 1;
            float t = mod(GameTime * 24000.0, 12000.0) / 20.0;
            float frame = floor((mod(t, DURATION) / DURATION) * FRAMES);
            float pick = mod(floor(texture(Sampler0, UV0).r * 255.0), FRAMES);
            if (pick == frame) vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
            else vertexColor *= 0.0;
            if      (gl_VertexID % 4 == 0) coord = vec2(0.0, 1.0);
            else if (gl_VertexID % 4 == 1) coord = vec2(0.0, 0.0);
            else if (gl_VertexID % 4 == 2) coord = vec2(1.0, 0.0);
            else                           coord = vec2(1.0, 1.0);
        }
    }

    if((int(round(Color.r * 255.0)) == 252 || int(round(Color.r * 255.0)) == 253) && int(round(Color.g * 255.0)) == 252) {
        vertexColor.rgb = vec3(1.0, 1.0, 1.0);

        int b = int(round(Color.b * 255.0));

        const float duration = 1.2;

        float t = 0.0;
        float s = -1.0;

        vec2 ts = vec2(textureSize(Sampler0, 0));
        
        texCoord0 -= vec2(96.0, 32.0) * corners[gl_VertexID % 4] / ts;
        //texCoord0 = corners[gl_VertexID % 4];

        for(int i = 0; i < 4; i++) {
            if(b == 2 * i || b == 2 * i + 1) {
                if(b == 2 * i + 1) {
                    texCoord0.y += 32.0 / ts.y;
                    s = 1.0;
                }

                texCoord0.x += i * 32.0 / ts.x;

                if(i == 0) { 
                    t = Color.a * 4.0;
                }else{
                    t = max(((Color.a * 4.0) - (i - 0.2)) / 1.2, 0.0);
                }
            }
        }

        float entranceT = max(t * 2.0, 0.0);
        if(int(round(Color.r * 255.0)) == 253) {
            t = Color.a * 2.0;
            entranceT = max(t * 4.0, 0.0);
        }

        vertexColor.a = clamp(min(8 * t, 4.0 - 4.0 * t), 0.0, 1.0);
        vertexColor.a = 1.0 - (1.0 - vertexColor.a) * (1.0 - vertexColor.a);


        float fallT = max((t - 0.75) / 0.25, 0.0);
        float angle = fallT * s;

        vec2 screenCoords = corners[gl_VertexID % 4] - 0.5;
        screenCoords *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        screenCoords.x *= ScreenSize.y / ScreenSize.x;
        screenCoords.y = -screenCoords.y;
        screenCoords.y += 0.3;
        screenCoords *= 0.6;
        screenCoords *= 1.0 - (pow(0.03, entranceT) * cos(TAU * 2.0 * entranceT));

        float shakeT = clamp((t - 0.6) / 0.15, 0.0, 1.0);
        screenCoords.x += (0.5 - 0.5 * cos(TAU * shakeT)) * cos(5.0 * TAU * shakeT) * 0.03;


        screenCoords.x += s * sqrt(fallT) * 0.25;
        screenCoords.y -= fallT * fallT * 0.25;

        gl_Position = vec4(screenCoords, 0.0, 1.0);

    }

    uint colId = colorId(Color.rgb);
    bool animateText = false;
    applyGlint = 0.0;

    if(colId == COLOR_ID_RGB(252, 253, 0)) {
        vertexColor = vec4(1.0);
        vertexColor.a = clamp(min(8 * Color.a, 4.0 - 4.0 * Color.a), 0.0, 1.0);
        vertexColor.a = 1.0 - (1.0 - vertexColor.a) * (1.0 - vertexColor.a);

        float angle = cos(Color.a * 100.0) * 0.1;

        vec2 screenCoords = corners[gl_VertexID % 4] - 0.5;
        screenCoords *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        screenCoords.x *= ScreenSize.y / ScreenSize.x;
        screenCoords.y = -screenCoords.y;
        screenCoords.y += 0.3;
        screenCoords *= 0.6;

        screenCoords.x += cos(Color.a * 90.0) * 0.002;
        screenCoords.y += sin(Color.a * 110.0) * 0.002;

        gl_Position = vec4(screenCoords, 0.0, 1.0);
    }

    isConfetti = 0.0;
    if(colId == COLOR_ID_RGB(253, 253, 1)) {
        isConfetti = 1.0;
        
        texCoord0 = corners[gl_VertexID % 4];
        vec2 screenCoords = corners[gl_VertexID % 4] * 2.0 - 1.0;
        screenCoords.y = -screenCoords.y;

        gl_Position = vec4(screenCoords, 0.0, 1.0);
    }

    if(colId == COLOR_ID_RGB(252, 253, 1)) {
        vertexColor = vec4(1.0);
        vertexColor.a = clamp(min(8 * Color.a, 4.0 - 4.0 * Color.a), 0.0, 1.0);
        vertexColor.a = 1.0 - (1.0 - vertexColor.a) * (1.0 - vertexColor.a);

        float t = min(8 * Color.a, 8.0 - 8.0 * Color.a);

        vec2 screenCoords = corners[gl_VertexID % 4] - 0.5;
        screenCoords *= 1.0 - (pow(0.01, t) * cos(TAU * 1.0 * t));
        screenCoords.x *= ScreenSize.y / ScreenSize.x;
        screenCoords.y = -screenCoords.y;
        screenCoords.y += 0.3;
        screenCoords *= 0.6;

        applyGlint = 1.0;

        gl_Position = vec4(screenCoords, 0.0, 1.0);
    }

    if(colId == COLOR_ID_RGB(252, 253, 2)) {
        vertexColor = vec4(1.0);
        vertexColor.a = clamp(min(8 * Color.a, 4.0 - 4.0 * Color.a), 0.0, 1.0);
        vertexColor.a = 1.0 - (1.0 - vertexColor.a) * (1.0 - vertexColor.a);

        float t = min(8 * Color.a, 8.0 - 8.0 * Color.a);

        vec2 screenCoords = corners[gl_VertexID % 4] - 0.5;
        screenCoords *= 1.0 - (pow(0.01, t) * cos(TAU * 1.0 * t));
        screenCoords.x *= ScreenSize.y / ScreenSize.x;
        screenCoords.y = -screenCoords.y;
        screenCoords.y += 0.5;
        screenCoords *= 0.5;

        gl_Position = vec4(screenCoords, 0.0, 1.0);
    }

    if(colId == COLOR_ID_RGB(252, 253, 3)) {
        vertexColor = vec4(1.0);

        float t = Color.a * 2.0;
        float s = -1.0;

        vertexColor.a = clamp(min(4 * t, 4.0 - 4.0 * t), 0.0, 1.0);
        vertexColor.a = 1.0 - (1.0 - vertexColor.a) * (1.0 - vertexColor.a);

        float entranceT = max(t * 2.0, 0.0);

        float fallT = max((t - 0.75) / 0.25, 0.0);
        float angle = fallT * s;

        vec2 screenCoords = corners[gl_VertexID % 4] - 0.5;
        screenCoords *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
        screenCoords.x *= ScreenSize.y / ScreenSize.x;
        screenCoords.y = -screenCoords.y;
        screenCoords.y += 0.5;
        screenCoords *= 0.5;
        //screenCoords *= 1.0 - (pow(0.03, entranceT) * cos(TAU * 2.0 * entranceT));

        float shakeT = clamp((t - 0.6) / 0.15, 0.0, 1.0);
        screenCoords.x += (0.5 - 0.5 * cos(TAU * shakeT)) * cos(5.0 * TAU * shakeT) * 0.03;


        screenCoords.x += s * sqrt(fallT) * 0.25;
        screenCoords.y -= fallT * fallT * 0.25;

        gl_Position = vec4(screenCoords, 0.0, 1.0);
    }

    if(colId == COLOR_ID_RGB(161, 81, 1)) {
        vertexColor = vec4(1.0, 0.25, 0.25, Color.a);
        animateText = true;
    }

    if(colId == COLOR_ID_RGB(40, 20, 0)) {
        vertexColor = vec4(0.3, 0.08, 0.08, Color.a);
        animateText = true;
    }

    if(colId == COLOR_ID_RGB(161, 81, 4)) {
        vertexColor = vec4(1.0, 0.75, 0.25, Color.a);
        animateText = true;
    }

    if(colId == COLOR_ID_RGB(40, 20, 1)) {
        vertexColor = vec4(0.3, 0.2, 0.08, Color.a);
        animateText = true;
    }

    if(colId == COLOR_ID_RGB(161, 81, 8)) {
        vertexColor = vec4(0.25, 1.0, 0.3, Color.a);
        animateText = true;
    }

    if(colId == COLOR_ID_RGB(40, 20, 2)) {
        vertexColor = vec4(0.08, 0.3, 0.1, Color.a);
        animateText = true;
    }

    if(animateText) {
        float offset = abs((gl_Position.x * 0.5 + 0.5) - Color.a) * 32.0;
        offset = max(1.0 - pow(offset, 5.0), 0.0);
        offset *= 0.03;

        float entranceT = Color.a * 8.0;
        offset -= pow(0.03, entranceT) * cos(1.5 * TAU * entranceT) * 0.2;

        gl_Position.y += offset;
        vertexColor.a = clamp(min(8 * Color.a, 4.0 - 4.0 * Color.a), 0.0, 1.0);
        vertexColor.a = 1.0 - (1.0 - vertexColor.a) * (1.0 - vertexColor.a);
    }

    if(colId == COLOR_ID_RGB(240, 4, 240)) {
        vertexColor = vec4(1.0);
        vec2 screenCoords = corners[gl_VertexID % 4] - 0.5;
        screenCoords *= 0.15;
        screenCoords.y = -screenCoords.y;
        screenCoords.x *= ScreenSize.y / ScreenSize.x;
        gl_Position = vec4(screenCoords, 0.0, 1.0);
    }
    
    if(colId == COLOR_ID_RGB(240, 8, 240)) {
        vertexColor = vec4(1.0);
        vec2 screenCoords = (corners[gl_VertexID % 4] - 0.5) * 6.0 * vec2(1.0, 35.0 / 66.0);
        texCoord0 -= corners[gl_VertexID % 4] * (vec2(128.0 - 66.0, 128.0 - 35.0) / 256.0);

        screenCoords *= 0.15;
        screenCoords.y = -screenCoords.y;
        screenCoords.x *= ScreenSize.y / ScreenSize.x;

        float x = mod(GameTime * 9.0 * 25.0, 2.0);
        float y = mod(GameTime * 16.0 * 25.0, 2.0);
        if(x > 1.0) x = 2.0 - x;
        if(y > 1.0) y = 2.0 - y;

        screenCoords.x += (x * 2.0 - 1.0) * (1.0 - abs(screenCoords.x));
        screenCoords.y += (y * 2.0 - 1.0) * (1.0 - abs(screenCoords.y));

        gl_Position = vec4(screenCoords, 0.0, 1.0);
    }

    if (Position.z == 0) {
        if (Color.xyz == vec3(1 / 255., 1 / 255., 1 / 255.)) {
            gl_Position = vec4(2, 2, 2, 1);
        }
        else if (Color.x == 63/255. && Color.y == 62/255. && Color.z == 63/255.) {
            gl_Position = vec4(2, 2, 2, 1);
        }
    }

    uint shadowColor = colorId(Color.rgb);
    if(shadowColor == COLOR_ID_RGB(63, 63, 0) || shadowColor == COLOR_ID_RGB(63,63,1) || shadowColor == COLOR_ID_RGB(60, 1, 60) || shadowColor == COLOR_ID_RGB(60, 2, 60))
        gl_Position = vec4(-10.0, -10.0, 0.0, 0.0);

    return true;
}
#endif

#ifdef FSH 
bool make_animated_escape(inout vec4 color) {
    if (isBanner == 1) {
        if (coord.x <= 1.0 / 255.0 || coord.x > 254.0 / 255.0) discard;
    }

    if(isConfetti > 0.0) {
        color = vec4(1.0, 0.0, 1.0, 1.0);
        bool hitOne = false;

        vec2 uv0 = texCoord0;
        uv0.y = 1.0 - uv0.y;
        uv0.x *= ScreenSize.x / ScreenSize.y;

        vec2 uv1 = texCoord0;
        uv1 = 1.0 - uv1;
        uv1.x *= ScreenSize.x / ScreenSize.y;

        const float g = 1.0;
        const float r = 0.01;

        for(int i = 0; i < 128; i++) {

            float angle = ((random(vec2(0.0, i)) * 0.1 + 0.1) * TAU);
            float f = random(vec2(i, 0.0)) * 0.5 + 0.5;
            float size = random(vec2(i, i)) * 0.5 + 0.8;

            float t = sqrt(vertexColor.a) * 5.0;
            float temp = sqrt(f) - (0.5 * g * t / sin(angle));
            float y = (f - temp * temp) * sin(angle) + 0.0;
            float x = f * cos(angle) * t * 0.75 - 0.2;

            vec2 toParticle1 = uv0 - vec2(x,y);
            vec2 toParticle2 = uv1 - vec2(x,y);
            if(dot(toParticle1, toParticle1) < r * r * size * size) {
                float rot = random(vec2(i, 5.0)) * TAU + 2.0 * t;
                mat2 rotationMatrix = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
                vec2 newUv = rotationMatrix * toParticle1;
                if(max(abs(newUv.x), abs(newUv.y)) < r * size * sqrt(0.5)) { 
                    hitOne = true;
                    color.rgb = hsvToRgb(vec3(random(vec2(i, i + 1)), 0.8, 1.0));
                }
            }
            if(dot(toParticle2, toParticle2) < r * r * size * size) {
                float rot = random(vec2(i, 4.0)) * TAU + 2.0 * t;
                mat2 rotationMatrix = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
                vec2 newUv = rotationMatrix * toParticle2;
                if(max(abs(newUv.x), abs(newUv.y)) < r * size * sqrt(0.5)) { 
                    hitOne = true;
                    color.rgb = hsvToRgb(vec3(random(vec2(i, i + 2)), 0.8, 1.0));
                }
            }
        }

        color.a = min(1.5 - 5.0 * vertexColor.a, 1.0);
        color.a = 1.0 - (1.0 - color.a) * (1.0 - color.a);

        if(!hitOne)
            discard;

    } else{    
        color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
        if (color.a < 0.1) {
            discard;
        }

        if(applyGlint > 0.5) {
            vec2 ts = vec2(textureSize(Sampler0, 0));
            vec2 pixelCoord = floor(texCoord0 * ts);

            float glintT = pixelCoord.x + pixelCoord.y - 32.0 - (glintTime * 2.0 - 0.5) * 32.0;
            color.rgb += (mod(glintT, 32.0) < 6.0) ? 0.5 : 0.0;
        }
    }

    return true;
}
#endif
#endif