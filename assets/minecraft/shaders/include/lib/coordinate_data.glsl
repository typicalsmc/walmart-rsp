#version 150

ivec3 extractCoordinateData(inout vec3 worldpos, bool ui) {
    ivec3 coordinateData = ui ? ivec3(0) : (ivec3(worldpos + 512.0) >> 10);
    worldpos = worldpos - vec3(coordinateData << 10);
    return coordinateData;
}