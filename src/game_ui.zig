const wasm4_module = @import("wasm4.zig");

pub fn getTitleTextPositionX() i32 {
    return 10;
}

pub fn getTitleTextPositionY() i32 {
    return 10;
}

pub fn drawArrowControls() void {
    // Left
    wasm4_module.text("\x84", 100, 140);
    // Down
    wasm4_module.text("\x87", 108, 140);
    // Up
    wasm4_module.text("\x86", 108, 132);
    // Right
    wasm4_module.text("\x85", 116, 140);
}

pub fn drawDialogLine() void {
    wasm4_module.rect(0, 100, 180, 4);
}