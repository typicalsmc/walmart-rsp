#version 150

#ifdef VSH
// Called in 'rendertype_item_entity_translucent_cull.vsh' - ONLY function that should be used; above is utilities.
bool make_skybox() {
    if (Color.rgb == vec3(0xCA, 0xFE, 0xBA) / 0xFF) {
        mat4 projMat = ProjMat;
        float zFar = 10000.0;
        float zNear = 0.5;
        projMat[2][2] = -1.0 * ((zFar + zNear) / (zFar - zNear));
        projMat[2][3] = -1.0 * ((2.0 * (zFar * zNear)) / (zFar - zNear));
        gl_Position = projMat * ModelViewMat * vec4(Position, 1.0);

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