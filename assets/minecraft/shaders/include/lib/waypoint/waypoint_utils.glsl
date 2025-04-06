#version 150

bool is_waypoint(sampler2D tex, ivec2 pixel) {
    return ivec4(texelFetch(tex, pixel, 0) * 255.5) == ivec4(157, 211, 147, 99);
}

vec4 build_waypoint(inout vec2 texCoord, ivec2 texSize, vec2 size, vec3 position, vec2 faceCoords, mat4 projMat, mat4 modelViewMat) {
    vec2 screenBounds = vec2(1.0, 1.0) - size * 1.0;

    ivec2 sprite = ivec2(0,0);
    vec4 center = modelViewMat * vec4(position - vec3(faceCoords, 0.0), 1.0);
    vec4 clipPos = projMat * center;
    vec2 screenPos = clipPos.xy / clipPos.w;

    if(clipPos.z < 0.0 || abs(screenPos.x) > screenBounds.x || abs(screenPos.y) > screenBounds.y) {
        if(center.z >= 0.0) screenPos *= -1.0;

        vec2 t = screenBounds / abs(screenPos);
        screenPos.xy *= min(t.x, t.y);
        sprite = ivec2(ivec2(2, -2) * screenPos);
    }

    vec2 uv = faceCoords + 0.5;
    uv.y = 1.0 - uv.y;
    uv = 33.0 + 30.0 * uv + 32.0 * sprite;
    texCoord = texCoord + uv / vec2(texSize);

    return vec4(screenPos.xy + size * faceCoords, -1.0, 1.0);
}

#ifdef VSH
// Called in 'rendertype_item_entity_translucent_cull.vsh' - ONLY function that should be used; above is utilities.
bool make_waypoint() {
    ivec2 texSize = textureSize(Sampler0, 0);
    ivec2 pixel = ivec2(UV0 * texSize);

    if(is_waypoint(Sampler0, pixel)) {
        vec2 faceCoords = vec2[](vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0))[gl_VertexID % 4];
        vec2 scaleFactor = clamp(max((100.0 - length(Position)), 0.0) / 100.0, 0.75, 1.0) * vec2(0.25);
        gl_Position = build_waypoint(
            texCoord0, 
            texSize, 
            scaleFactor / vec2(ScreenSize.x / ScreenSize.y, 1.0), 
            Position, 0.5 * faceCoords, 
            ProjMat, 
            ModelViewMat
        );

        // Render flat
        vertexDistance = 0.0;
        vertexColor = vec4(1.0);
        lightColor = vec4(1.0);
        faceLightColor = vec4(1.0);

        return true;
    }

    return false;
}
#endif