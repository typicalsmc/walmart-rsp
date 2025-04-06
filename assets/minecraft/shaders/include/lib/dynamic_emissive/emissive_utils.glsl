/**
 * Source:
 * https://github.com/ShockMicro/VanillaDynamicEmissives/tree/main
 *
 * NOTE (8Blits): Modified IMPL for 1.21.3+ support. 
 */

#version 150

// For cases in which you want something to have a lower light level, but still be bright when in light.
vec4 apply_partial_emissivity(vec4 color, vec4 originalLightColor, vec3 minimumLightColor) {
    vec4 newLightColor = originalLightColor;
    newLightColor.r = max(originalLightColor.r, minimumLightColor.r);
    newLightColor.g = max(originalLightColor.g, minimumLightColor.g);
    newLightColor.b = max(originalLightColor.b, minimumLightColor.b);
    return color * newLightColor;
}

// Makes sure transparent things don't become solid and vice versa.
float remap_alpha(int inputAlpha) {
    if (inputAlpha == 252) return 255.0; // Checks for alpha 252 and converts all pixels of that to alpha 255. Used in the example pack for redstone ore and the zombie's eyes.
    if (inputAlpha == 251) return 120.0; // You can copy & paste this line and change the values to make any transparent block work with this pack. Used in the example pack for ice.
    if (inputAlpha == 250) return 0.0; // Hide (3D Handheld)
    if (inputAlpha == 249) return 0.0; // Hide (2D GUI)
    if (inputAlpha == 248) return 0.0; // Hide (3D Handheld & Emissive)
    
    return float(inputAlpha); // If a pixel doesn't need to have its alpha changed then it simply does not change.
}

#ifdef FSH
// The meat and bones of the pack, does all the work for making things emissive.
bool make_emissive(inout vec4 color, vec4 pureColor, vec4 tintColor) {
    vec3 emissiveColor = pureColor.rgb * tintColor.rgb;
    int alpha = int(round(pureColor.a * 255.0));
    color.a = remap_alpha(alpha) / 255.0; // Remap the alpha value

    if (alpha == 252) {
        color.rgb = emissiveColor;
        return true;
    }
    if (alpha == 2 || alpha == 27 || alpha == 52 || alpha == 77 || alpha == 102 || alpha == 127 || alpha == 152 || alpha == 177 || alpha == 202 || alpha == 227) {
        color.rgb = emissiveColor;
        return true;
    }
    if (alpha == 251) {
        color = apply_partial_emissivity(color, faceLightColor, vec3(0.411, 0.345, 0.388)); // Used in the example pack for ice.
        return true;
    }

    // 2D GUI with 3D Handheld
    
    bool guiState = bool(FogShape == 0.0 && ProjMat[3][3] != 0.0);
    if (alpha == 250) { // 3D
        // TODO: Need to make visible for GUI Player

        if (!guiState) color.a = 1.0; // Visible for First/3rd Person
    }
    if (alpha == 248) { // 3D & Emissive
        color.rgb = emissiveColor;
        if (!guiState) color.a = 1.0; // Visible for First/3rd Person
    }
    if (alpha == 249) { // 2D
        if (guiState) color.a = 1.0; // Visible for HUD/Inventory; excluding GUI Viewport
        return true;
    }

    return false;
}
#endif