#version 150

#moj_import <lib/video_player/map_decode.glsl>

#ifdef RENDERTYPE_TEXT
#ifdef VSH
bool make_video_player() {
    coord = vec2(0.0);
    isBanner = 0;
    isVideoDisplay = 0;
    videoWidth = 0;
    videoHeight = 0;
    videoX = 0;
    videoY = 0;

    ivec2 texSize = textureSize(Sampler0, 0).xy;
    if (texSize == ivec2(128, 128)) {
        int magic1 = decode7u(texelFetch(Sampler0, ivec2(1, 1), 0).rgb) >> 3;
        int magic2 = decode7u(texelFetch(Sampler0, ivec2(3, 1), 0).rgb) >> 3;
        int magic3 = decode7u(texelFetch(Sampler0, ivec2(5, 1), 0).rgb) >> 3;
        int magic4 = decode7u(texelFetch(Sampler0, ivec2(7, 1), 0).rgb) >> 3;
        if (magic1 == 0xC && magic2 == 0xA && magic3 == 0xF && magic4 == 0xE) {
            int width  = (decode7u(texelFetch(Sampler0, ivec2(9 , 1), 0).rgb) >> 3) + 1;
            int height = (decode7u(texelFetch(Sampler0, ivec2(11, 1), 0).rgb) >> 3) + 1;
            int x      =  decode7u(texelFetch(Sampler0, ivec2(13, 1), 0).rgb) >> 3;
            int y      =  decode7u(texelFetch(Sampler0, ivec2(15, 1), 0).rgb) >> 3;
            isVideoDisplay = 1;
            videoWidth = width;
            videoHeight = height;
            videoX = x;
            videoY = y;

            vec2 faceCoords = vec2[](vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0))[gl_VertexID % 4];

            texCoord0 = UV0;
            texCoord0.y = 1.0 - texCoord0.y;
            gl_Position = vec4(faceCoords, -1.0, 1.0);
            return false;
        }
    }

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    glintTime = Color.a;

    return false;
}
#endif

#ifdef FSH
bool make_video_player() {
    ivec2 texSize = textureSize(Sampler0, 0).xy;
    if (isVideoDisplay == 1 && texSize == ivec2(128, 128)) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);

        vec2 texCoord = texCoord0.yx;
        float aspect = float(videoWidth) / videoHeight;
        float screenAspect = ScreenSize.x / ScreenSize.y;

        if (aspect > screenAspect) {
            float height = 1.0 / aspect;
            float screenHeight = 1.0 / screenAspect;
            float ratio = height / screenHeight;
            texCoord.y = (texCoord.y - ((1.0 - ratio) / 2.0)) / ratio;
            if (texCoord.y < 0 || texCoord.y > 1) {
                return false;
            }
        } else {
            float width = aspect;
            float screenWidth = screenAspect;
            float ratio = width / screenWidth;
            texCoord.x = (texCoord.x - ((1.0 - ratio) / 2.0)) / ratio;
            if (texCoord.x < 0 || texCoord.x > 1) {
                return false;
            }
        }

        float x = texCoord.x * videoWidth - videoX;
        float y = texCoord.y * videoHeight - videoY;
        if (x < 0.0 || x > 1.0 || y < 0.0 || y > 1.0) {
            discard;
        }

        ivec2 coord = (ivec2(floor(vec2(x, y) * vec2(texSize))) / 2) * 2;
        int r = decode7u(texelFetch(Sampler0, coord, 0).rgb);
        int g = decode7u(texelFetch(Sampler0, coord + ivec2(1, 0), 0).rgb);
        int b = decode7u(texelFetch(Sampler0, coord + ivec2(0, 1), 0).rgb);
        int extra = decode7u(texelFetch(Sampler0, coord + ivec2(1, 1), 0).rgb);
        r |= (extra & 1) << 7; 
        g |= (extra & 2) << 6; 
        b |= (extra & 4) << 5;
        fragColor = vec4(vec3(r, g, b) / 255.0, 1.0);
        return false;
    }

    return true;
}
#endif
#endif