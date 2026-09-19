#version 330

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;

out vec4 vertexColor;
out vec2 texCoord0;
flat out int waypointDistanceText;

const ivec3 WAYPOINT_DISTANCE_COLOR = ivec3(157, 211, 147);
const float WAYPOINT_LABEL_Y_OFFSET = -0.18;

bool is_waypoint_distance_text(vec4 color) {
    return ivec3(color.rgb * 255.0 + 0.5) == WAYPOINT_DISTANCE_COLOR;
}

vec2 waypoint_screen_bounds(vec3 viewPosition) {
    vec2 aspect = vec2(ScreenSize.x / ScreenSize.y, 1.0);
    vec2 iconHalfSize = clamp(max((100.0 - length(viewPosition)), 0.0) / 100.0, 0.75, 1.0) * vec2(0.25);
    return vec2(1.0) - iconHalfSize / aspect;
}

vec4 clamp_waypoint_label(vec4 vertexClipPosition) {
    vec4 anchorViewPosition = ModelViewMat * vec4(0.0, 0.0, 0.0, 1.0);
    vec4 anchorClipPosition = ProjMat * anchorViewPosition;
    vec2 anchorScreenPosition = anchorClipPosition.xy / anchorClipPosition.w;
    vec2 screenBounds = waypoint_screen_bounds(anchorViewPosition.xyz);

    if (anchorClipPosition.z >= 0.0
            && abs(anchorScreenPosition.x) <= screenBounds.x
            && abs(anchorScreenPosition.y) <= screenBounds.y) {
        return vertexClipPosition;
    }

    vec2 clampedAnchorPosition = anchorScreenPosition;
    if (anchorViewPosition.z >= 0.0) {
        clampedAnchorPosition *= -1.0;
    }

    vec2 t = screenBounds / max(abs(clampedAnchorPosition), vec2(0.0001));
    clampedAnchorPosition *= min(t.x, t.y);

    vec2 vertexScreenPosition = vertexClipPosition.xy / vertexClipPosition.w;
    vec2 vertexOffset = vertexScreenPosition - anchorScreenPosition;
    return vec4(clampedAnchorPosition + vertexOffset + vec2(0.0, WAYPOINT_LABEL_Y_OFFSET), -1.0, 1.0);
}

void main() {
    vec4 vertexClipPosition = ProjMat * ModelViewMat * vec4(Position, 1.0);

    waypointDistanceText = is_waypoint_distance_text(Color) ? 1 : 0;
    if (waypointDistanceText == 1) {
        gl_Position = clamp_waypoint_label(vertexClipPosition);
    } else {
        gl_Position = vertexClipPosition;
    }

    vertexColor = Color;
    texCoord0 = UV0;
}
