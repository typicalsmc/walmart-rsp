#version 150

vec4 sampleSkinQuad(sampler2D skin, ivec2 pixel, ivec2 position, ivec2 size, ivec2 baseCoords, ivec2 hatCoords, ivec2 skinSize) {
    if(pixel.x < position.x || pixel.y < position.y || pixel.x >= position.x + size.x || pixel.y >= position.y + size.y)
        return vec4(0.0);

    ivec2 relativePosition = pixel - position;
    relativePosition = ivec2(vec2(relativePosition * skinSize) / vec2(size));

    vec4 baseSample = texelFetch(skin, baseCoords + relativePosition, 0);
    vec4 hatSample = texelFetch(skin, hatCoords + relativePosition, 0);

    return vec4(mix(baseSample.rgb, hatSample.rgb, hatSample.a), 1.0 - (1.0 - baseSample.a) * (1.0 - hatSample.a));
}

vec4 samplePlayerSprite(sampler2D skin, vec2 skinUv, int spriteId, float time) {
    ivec2 skinSize = textureSize(skin, 0);
    ivec2 pixel = ivec2((skinUv * skinSize * 2.0 - 16.0) / 16.0 * 17.0) - 1;
    
    // only render front face
    if(pixel.x < 0 || pixel.y < 0 || pixel.x >= 16 || pixel.y >= 16)
        return vec4(0.0);

    ivec2 headPosition = ivec2(4,1);
    ivec2 bodyPosition = ivec2(4,9);
    ivec2 lArmPosition = ivec2(3,10);
    ivec2 rArmPosition = ivec2(12,10);
    ivec2 lLegPosition = ivec2(4, 14);
    ivec2 rLegPosition = ivec2(9, 14);

    int bodyHeightOffset = 0;
    bool bodyClip = false;
    bool lArmShadow = false;
    bool rArmShadow = true;

    // time in seconds
    float t = time * 24000.0 / 20.0;
    float fps = 10.0;

    // idle animation
    if (spriteId == 1) {
        float frames = 8.0;
        float duration = frames / fps;
        int frame = int(mod(t / duration, 1.0) * frames);
        if (frame == 2 || frame == 3) {
            headPosition.y += 1;
        } else if (frame == 6 || frame == 7) {
            headPosition.y += -1;
            bodyPosition.y += -1;
            lArmPosition.y += -1;
            rArmPosition.y += -1;
            bodyHeightOffset = 1;
        }
    }
    // interact animation
    else if (spriteId == 2) {
        float frames = 6.0;
        float duration = frames / fps;
        int frame = int(mod(t / duration, 1.0) * frames);
        if (frame == 0) {
            headPosition.y += 1;
        } else if (frame == 1) {
            lArmPosition.y += 1;
            rArmPosition.y += -2;
        } else if (frame == 2) {
            headPosition.y += -1;
            bodyPosition.y += -1;
            lArmPosition.y += -1;
            rArmPosition.y += -1;
            bodyHeightOffset = 1;
        } else if (frame == 5) {
            headPosition.y += 1;
        }
        if (frame >= 2) {
            lArmShadow = true;
            rArmShadow = false;
        }
    }
    // walk animation
    else if (spriteId == 3) {
        float frames = 4.0;
        float duration = frames / fps;
        int frame = int(mod(t / duration, 1.0) * frames);
        if (frame == 0) {
            headPosition += ivec2(1, -1);
            bodyPosition += ivec2(1, -1);
            lArmPosition += ivec2(1, -2);
            rArmPosition += ivec2(1, 1);
            lLegPosition.x += 2;
            rLegPosition.x += -1;
            bodyHeightOffset = 1;
        } else if (frame == 1) {
            headPosition.y += 1;
            lLegPosition.x += 1;
            rLegPosition += ivec2(1, -1);
        } else if (frame == 2) {
            headPosition.y += 2;
            bodyPosition.y += 1;
            lArmPosition.y += 2;
            rArmPosition.y += -1;
            rLegPosition.x += 1;
        } else if (frame == 3) {
            headPosition += ivec2(1, 1);
            bodyPosition.y += 1;
            lArmPosition.y += 1;
            lLegPosition += ivec2(1, -1);
        }
    }
    // jump animation
    else if (spriteId == 4) {
        float frames = 3.0;
        float duration = frames / fps;
        int frame = int(mod(t / duration, 1.0) * frames);
        rArmShadow = false;
        if (frame == 0) {
            headPosition.y += 1;
        } else if (frame == 1) {
            bodyClip = true;
            headPosition.y += 2;
            bodyPosition.y += 1;
            lArmPosition.y += 2;
            rArmPosition.y += 2;
        } else if (frame == 2) {
            headPosition.y += -1;
            bodyPosition.y += -1;
            lArmPosition.y += -2;
            rArmPosition.y += -2;
            bodyHeightOffset = 1;
            rLegPosition.y += -1;
        }
    }
    // crouch animation
    else if (spriteId == 5) {
        bodyClip = true;
        rArmShadow = false;
        headPosition += ivec2(2, 2);
        bodyPosition.y += 1;
        lArmPosition += ivec2(2, 3);
        rArmPosition += ivec2(-1, 2);
        rLegPosition.x += -1;
    }
    // mid-jump animation
    else if (spriteId == 6) {
        float frames = 4.0;
        float duration = frames / fps;
        int frame = int(mod(t / duration, 1.0) * frames);
        rArmShadow = false; 
        if (frame == 0) {
            headPosition.y += -1;
            bodyPosition.y += -1;
            lArmPosition += ivec2(-2, -3);
            rArmPosition += ivec2(2, -3);
            lLegPosition.y += -1;
            rLegPosition.y += -3;
        } else if (frame == 1) {
            headPosition.y += -1;
            bodyPosition.y += -1;
            lArmPosition += ivec2(-1, -2);
            rArmPosition += ivec2(1, -4);
            lLegPosition.y += -1;
            rLegPosition.y += -3;
        } else if (frame == 2) {
            headPosition.y += 1;
            bodyPosition.y += -1;
            bodyHeightOffset = 1;
            lArmPosition.x += -2;
            rArmPosition += ivec2(1, -5);
            rLegPosition.y += -2;
        } else if (frame == 3) {
            bodyPosition.y += -1;
            bodyHeightOffset = 1;
            lArmPosition += ivec2(-2, -2);
            rArmPosition += ivec2(2, -4);
            rLegPosition.y += -2;
        }
    }

    vec4 head = sampleSkinQuad(skin, pixel, headPosition, ivec2(8, 8), ivec2(8,8), ivec2(40, 8), ivec2(8, 8));
    if(head.a > 0.0)
        return head;

    vec4 lArm = sampleSkinQuad(skin, pixel, lArmPosition, ivec2(2 - int(lArmShadow), 2), ivec2(48, 17), ivec2(48, 33), ivec2(2, 2)) * vec4(vec3(1.0 - int(lArmShadow) * 0.2), 1.0);
    if(lArm.a > 0.0)
        return lArm;

    vec4 rArm = sampleSkinQuad(skin, pixel, rArmPosition + ivec2(-1 + int(rArmShadow), 0.0), ivec2(2 - int(rArmShadow), 2), ivec2(41, 49), ivec2(57, 49), ivec2(1, 2)) * vec4(vec3(1.0 - int(rArmShadow) * 0.2), 1.0);
    if(rArm.a > 0.0)
        return rArm;

    vec4 body = sampleSkinQuad(skin, pixel, bodyPosition, ivec2(8, 5 + bodyHeightOffset), ivec2(20, 20), ivec2(20, 36), ivec2(8, 12)) * vec4(0.9, 0.9, 0.95, 1.0);

    if(bodyClip && body.a > 0.0)
        return body;

    vec4 lLeg = sampleSkinQuad(skin, pixel, lLegPosition, ivec2(4, 2), ivec2(4, 30), ivec2(4, 46), ivec2(4, 2));
    if(lLeg.a > 0.0)
        return lLeg;

    vec4 rLeg = sampleSkinQuad(skin, pixel, rLegPosition, ivec2(4, 2), ivec2(20, 62), ivec2(4, 62), ivec2(4, 2));
    if(rLeg.a > 0.0)
        return rLeg;


    if(body.a > 0.0)
        return body;

    return vec4(0.0);
    //return bool((pixel.x + pixel.y) & 1) ? vec4(vec3(0.8), 0.5) : vec4(vec3(0.9), 0.5);
}