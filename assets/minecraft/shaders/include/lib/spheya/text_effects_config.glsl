// Vanilla Override START
// §4 - recipe book offset
TEXT_EFFECT(170, 0, 0) {
    remove_text_shadow();
    offset(-48.0, 0.0);
    override_text_color(rgb(255, 255, 255));
}

// §5 - removes text shadow for lang files
TEXT_EFFECT(170, 0, 170) {
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
}
// Vanilla Override END

// Dialogue START
// Container #c8c8b4
TEXT_EFFECT(200, 200, 190) {
    override_text_color(rgb(255, 255, 255));
    set_depth(-0.1);
}
// Title #c8c8b4
TEXT_EFFECT(200, 200, 180) {
    offset(0.0, 14.0);
    override_text_color(rgb(255, 255, 255));
    set_depth(-0.1);
}
// Y 0 #c8c8b1
TEXT_EFFECT(200, 200, 177) {
    offset(0.0, -2.0);
    override_text_color(rgb(255, 255, 255));
    set_depth(-0.1);
}
// Y 1 #c8c8ae
TEXT_EFFECT(200, 200, 174) {
    offset(0.0, -11.0);
    override_text_color(rgb(255, 255, 255));
    set_depth(-0.1);
}
// Y 2 #c8c8a8
TEXT_EFFECT(200, 200, 168) {
    offset(0.0, -20.0);
    override_text_color(rgb(255, 255, 255));
    set_depth(-0.1);
}
// Y 3 #c8c8a5
TEXT_EFFECT(200, 200, 165) {
    offset(0.0, -29.0);
    override_text_color(rgb(255, 255, 255));
    set_depth(-0.1);
}
// Y 4 #c8c8a2
TEXT_EFFECT(200, 200, 162) {
    offset(0.0, -100.0);
    override_text_color(rgb(255, 255, 255));
    set_depth(-0.1);
}
// Dialogue END

// SloverHUD START
TEXT_EFFECT(4, 4, 4) { // #040404
    remove_text_shadow();
}
// SloverHUD END

// Book START
TEXT_EFFECT(8, 8, 8) { // Container
    offset(-36.0, 0.0);
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
    
}
TEXT_EFFECT(30, 38, 84) { // Text #1e2654
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
    apply_outline(rgb(30, 38, 84));
}
// Book END

// Custom START
TEXT_EFFECT(12, 12, 12) { // Jetpack #0c0c0c
    offset(0.0, -16.0);
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
}
TEXT_EFFECT(12, 12, 16) { // Default Progress #0c0c10
    offset(0.0, 4.0);
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
}
TEXT_EFFECT(12, 12, 28) { // Jetpack Shaking #0c0c1c
    offset(0.0, -16.0);
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
    apply_shaking_movement(256.0);
}
TEXT_EFFECT(12, 12, 32) { // Jetpack Shaking #0c0c20
    offset(0.0, -16.0);
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
    apply_shaking_movement(128.0);
}

TEXT_EFFECT(12, 12, 36) { // Grey Waiting #0c0c24
    override_text_color(rgb(170, 170, 170));
    apply_iterating_movement();
    set_depth(-0.1);
}
TEXT_EFFECT(12, 12, 40) { // Blue Select #0c0c28
    override_text_color(rgb(39, 176, 211)); // #27b0d3
    apply_iterating_movement();
    set_depth(-0.1);
}
TEXT_EFFECT(12, 12, 44) { // Icon adjust #0c0c2c
    // offset(0.0, 0.0);
    override_text_color(rgb(255, 255, 255));
    apply_iterating_movement();
    set_depth(-0.1);
}

TEXT_EFFECT(12, 12, 48) { // Default Progress Shake #0c0c30
    offset(0.0, 4.0);
    remove_text_shadow();
    override_text_color(rgb(255, 255, 255));
    apply_shaking_movement(256.0);
}

TEXT_EFFECT(12, 12, 52) { // Bossbar Shake #0c0c34
    override_text_color(rgb(255, 255, 255));
    apply_shaking_movement(32.0);
}

TEXT_EFFECT(12, 12, 56) { // Keycode Padding #0c0c38
    override_text_color(rgb(255, 255, 255));
    keycode_padding(rgb(70, 77, 113), rgb(102, 111, 148), rgb(58, 42, 85));
}

TEXT_EFFECT(12, 12, 60) { // Generic Outline #0c0c3c
    override_text_color(rgb(255, 255, 255));
    apply_outline(rgb(0, 0, 0));
}

TEXT_EFFECT(12, 12, 64) { // Grey Waiting #0c0c40
    override_text_color(rgb(170, 170, 170));
    set_depth(-0.1);
}

TEXT_EFFECT(12, 12, 68) { // Chapter Left #0c0c44
    override_text_color(rgb(170, 170, 170));
    set_depth(-0.1);
}

TEXT_EFFECT(12, 12, 72) { // Chapter Right #0c0c48
    override_text_color(rgb(235, 177, 53));
    apply_shimmer(0.5, 0.5);
    set_depth(-0.1);
}
// Custom END