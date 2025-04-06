#version 150

#moj_import <lib/2d/player_sprites.glsl>

void createOrthographicMatrices(inout mat4 projMat, float orthographicSize) {
    float aspect = projMat[1][1] / projMat[0][0];
    projMat = mat4(
        2.0 / (aspect * orthographicSize), 0.0, 0.0, 0.0,
        0.0, 2.0 / orthographicSize, 0.0, 0.0,
        0.0, 0.0, -1.0 / 500.0, 0.0,
        0.0, 0.0, -1.0, 1.0
    );
}

void removeCameraRotation(inout mat4 viewMat) {
    viewMat = mat4(1.0);
}

#ifdef VSH
bool make_2d_world(mat4 projMat, mat4 viewMat, vec3 worldPos, int isGUI, ivec3 coordinateData, inout int is2D) {
    if(coordinateData.y < 0) {
        is2D = 1;

        // Apply camera
        createOrthographicMatrices(projMat, 16.0);
        removeCameraRotation(viewMat);

        // Remove light color
        vertexColor = vec4(1.0);
        lightColor = vec4(1.0);
        faceLightColor = vec4(1.0);

        gl_Position = projMat * viewMat * vec4(worldPos, 1.0);
        gl_Position.z += 0.5;
        return true;
    }
    return false;
}
#endif

#ifdef FSH
bool make_2d_world_tint(inout vec4 color, vec4 tintColor) {
    if (is2D != 0) {
        color.rgb *= tintColor.rgb;
    }
    return true;
}

bool make_2d_player(inout vec4 color, ivec3 coordinateData) {
    if(coordinateData.y != 0) {
        color = samplePlayerSprite(Sampler0, texCoord0, -coordinateData.y, GameTime);

        // Outline
        if(color.a != 1.0)
            for(int x = -1; x <= 1; ++x)
                for(int y = -1; y <= 1; ++y)
                    if(samplePlayerSprite(Sampler0, texCoord0 + 0.5 * vec2(x,y) / vec2(textureSize(Sampler0, 0)), -coordinateData.y, GameTime).a == 1.0)
                        color = vec4(0.0, 0.0, 0.0, 1.0);
    }
    return true;
}
#endif