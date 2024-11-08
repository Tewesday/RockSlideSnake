// Collection of utility functions for manipulating the display of the WASM-4 fantasy console.

const std = @import("std");

const wasm4_module = @import("wasm4.zig");

// Set each pixel (byte) in framebuffer to color 1
pub fn fill_c1() void {
    for (wasm4_module.FRAMEBUFFER) |*x| {
        x.* = 0x0;
    }
}

// Set each pixel (byte) in framebuffer to color 2
pub fn fill_c2() void {
    for (wasm4_module.FRAMEBUFFER) |*x| {
        x.* = 0x55;
    }
}

// Set each pixel (byte) in framebuffer to color 3
pub fn fill_c3() void {
    for (wasm4_module.FRAMEBUFFER) |*x| {
        x.* = 0xaa;
    }
}

// Set each pixel (byte) in framebuffer to color 4
pub fn fill_c4() void {
    for (wasm4_module.FRAMEBUFFER) |*x| {
        x.* = 0xff;
    }
}

// Draw time starting at X and Y positions 32px wide
pub fn renderTimeAsText(minutes: u8, seconds: u8, atX: i32, atY: i32) void {
    // Two numbers in text is about 14 pixels width
    // : is 2 pixels wide but needs 5 pixels for padding
    // 59     :     59
    // 14px  5px    14px
    // 32px wide for minutes timer

    // Make buffer and render seconds
    const max_len = 20;

    var buf: [max_len]u8 = undefined;
    if (seconds < 10) {
        // Add 0 before < 10 seconds
        wasm4_module.text("0", atX + 19, atY);

        buf = undefined;
        const timePassedSecondsAsString = std.fmt.bufPrint(&buf, "{}", .{seconds}) catch unreachable;
        wasm4_module.text(timePassedSecondsAsString, atX + 19 + 8, atY);
    }
    else {
        const timePassedSecondsAsString = std.fmt.bufPrint(&buf, "{}", .{seconds}) catch unreachable;
        wasm4_module.text(timePassedSecondsAsString, atX + 19, atY);
    }

    // Render : between minutes and seconds
    wasm4_module.text(":", atX + 14, atY);
    
    // Reset buffer and render minutes
    buf = undefined;
    if (minutes < 10) {
        // Add padding before minutes
        wasm4_module.text(" ", atX, atY);
        
        const timePassedMinutesAsString = std.fmt.bufPrint(&buf, "{}", .{minutes}) catch unreachable;
        wasm4_module.text(timePassedMinutesAsString, atX + 7, atY);
    }
    else {
        const timePassedMinutesAsString = std.fmt.bufPrint(&buf, "{}", .{minutes}) catch unreachable;
        wasm4_module.text(timePassedMinutesAsString, atX, atY);
    }
}

// Draw time starting at X and Y positions 52px wide
// Fragility note: Expects less than 100 hours of time.
pub fn renderHoursTimeAsText(hours: u32, minutes: u8, seconds: u8, atX: i32, atY: i32) void {
    // Two numbers in text is about 14 pixels width
    // : is 2 pixels wide but needs 5 pixels for padding
    // 59     :     59       :      59
    // 14px  5px    14px    5px     14px
    // 52px wide for minutes timer

    // Make buffer and render seconds
    const max_len = 20;

    var buf: [max_len]u8 = undefined;
    if (seconds < 10) {
        // Add 0 before < 10 seconds
        wasm4_module.text("0", atX + 38, atY);

        buf = undefined;
        const timePassedSecondsAsString = std.fmt.bufPrint(&buf, "{}", .{seconds}) catch unreachable;
        wasm4_module.text(timePassedSecondsAsString, atX + 38 + 8, atY);
    }
    else {
        const timePassedSecondsAsString = std.fmt.bufPrint(&buf, "{}", .{seconds}) catch unreachable;
        wasm4_module.text(timePassedSecondsAsString, atX + 38, atY);
    }

    // Render : between minutes and seconds
    wasm4_module.text(":", atX + 14 + 19, atY);
    
    // Reset buffer and render minutes
    buf = undefined;
    if (minutes < 10) {
        // Add 0 before < 10 minutes
        wasm4_module.text("0", atX + 19, atY);
        
        const minutesAsString = std.fmt.bufPrint(&buf, "{}", .{minutes}) catch unreachable;
        wasm4_module.text(minutesAsString, atX + 19 + 8, atY);
    }
    else {
        const minutesAsString = std.fmt.bufPrint(&buf, "{}", .{minutes}) catch unreachable;
        wasm4_module.text(minutesAsString, atX + 19, atY);
    }

    // Render : between hours and minutes
    wasm4_module.text(":", atX + 14, atY);

    // Reset buffer and render hours
    buf = undefined;
    if (hours < 10) {
        // Add padding before hours
        wasm4_module.text(" ", atX, atY);
        
        const hoursAsString = std.fmt.bufPrint(&buf, "{}", .{hours}) catch unreachable;
        wasm4_module.text(hoursAsString, atX + 8, atY);
    }
    else {
        const hoursAsString = std.fmt.bufPrint(&buf, "{}", .{hours}) catch unreachable;
        wasm4_module.text(hoursAsString, atX, atY);
    }
}