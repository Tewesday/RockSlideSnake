const std = @import("std");

// Data for tracking time
// Use increment and elapse functions to count time up
// Use decrement and reduce functions to count time down
pub const TimeTracker = struct {
    // Frames counted in this second
    frameCount: u8,
    // Seconds elapsed before carried over to minutes
    seconds: u8,
    // Minutes elapsed before carried over to hours
    minutes: u8,
    // Hours elapsed
    hours: u32,
};

pub fn setTimeValuesZero(timeT: *TimeTracker) void {
    timeT.frameCount = 0;
    timeT.seconds = 0;
    timeT.minutes = 0;
    timeT.hours = 0;
}

pub fn setTimeValuesFrames(timeT: *TimeTracker, frameCount: u8) void {
    timeT.frameCount = frameCount;
    timeT.seconds = 0;
    timeT.minutes = 0;
    timeT.hours = 0;
}

pub fn setTimeValuesSeconds(timeT: *TimeTracker, frameCount: u8, seconds: u8) void {
    timeT.frameCount = frameCount;
    timeT.seconds = seconds;
    timeT.minutes = 0;
    timeT.hours = 0;
}

pub fn setTimeValuesMinutes(timeT: *TimeTracker, frameCount: u8, seconds: u8, minutes: u8) void {
    timeT.frameCount = frameCount;
    timeT.seconds = seconds;
    timeT.minutes = minutes;
    timeT.hours = 0;
}

pub fn setTimeValuesHours(timeT: *TimeTracker, frameCount: u8, seconds: u8, minutes: u8, hours: u32) void {
    timeT.frameCount = frameCount;
    timeT.seconds = seconds;
    timeT.minutes = minutes;
    timeT.hours = hours;
}

// Convenience function since sequence matters
pub fn trackTimeIncreasing(timeT: *TimeTracker) void {
    _ = incrementFrameCount(timeT);
    _ = tryElapseFrameCount(timeT);
    _ = tryElapseSeconds(timeT);
    _ = tryElapseMinutes(timeT);
}

// Convenience function since sequence matters
pub fn trackTimeDecreasing(timeT: *TimeTracker) void {
    _ = tryReduceHours(timeT);
    _ = tryReduceMinutes(timeT);
    _ = tryReduceSeconds(timeT);
    _ = decrementFrameCount(timeT);
}

// Increments frameCount of TimeTracker 
// returns total frameCount
pub fn incrementFrameCount(timeT: *TimeTracker) u8 {
    timeT.frameCount += 1;
    return timeT.frameCount;
}

// Try to increment seconds of TimeTracker if frameCount >= 60
// returns total frameCount
pub fn tryElapseFrameCount(timeT: *TimeTracker) u8 {
    if (timeT.frameCount >= 60) {
        timeT.frameCount = 0;
        timeT.seconds += 1;
    }
    return timeT.frameCount;
}

// Try to increment minutes of TimeTracker if seconds >= 60
// returns total seconds
pub fn tryElapseSeconds(timeT: *TimeTracker) u8 {
    if (timeT.seconds >= 60) {
        timeT.seconds = 0;
        timeT.minutes += 1;
    }
    return timeT.seconds;
}

// Try to increment minutes of TimeTracker if seconds >= 60
// returns total minutes
pub fn tryElapseMinutes(timeT: *TimeTracker) u8 {
    if (timeT.minutes >= 60) {
        timeT.minutes = 0;
        timeT.hours += 1;
    }
    return timeT.minutes;
}

// Increments frameCount of TimeTracker 
// returns total frameCount
pub fn decrementFrameCount(timeT: *TimeTracker) u8 {
    if (timeT.frameCount > 0) {
        timeT.frameCount -= 1;
    }
    return timeT.frameCount;
}

// Try to decrement seconds of TimeTracker if frameCount == 0
// returns total seconds
pub fn tryReduceSeconds(timeT: *TimeTracker) u8 {
    if (timeT.frameCount == 0) {
        if (timeT.seconds > 0) {
            timeT.seconds -= 1;
            timeT.frameCount = 60;
        }
    }
    return timeT.seconds;
}

// Try to decrement minutes of TimeTracker if seconds == 0
// returns total minutes
pub fn tryReduceMinutes(timeT: *TimeTracker) u8 {
    if (timeT.seconds == 0) {
        if (timeT.minutes > 0) {
            timeT.minutes -= 1;
            timeT.seconds = 60;
        }
    }
    return timeT.minutes;
}

// Try to decrement hours of TimeTracker if minutes == 0
// returns total hours
pub fn tryReduceHours(timeT: *TimeTracker) u32 {
    if (timeT.minutes == 0) {
        if (timeT.hours > 0) {
            timeT.hours -= 1;
            timeT.minutes = 60;
        }
    }
    return timeT.hours;
}

test "Count Up One Second" {
    var timeT: TimeTracker = .{
        .frameCount = 0,
        .seconds = 0,
        .minutes = 0,
        .hours = 0
    };

    var frameCount: u8 = 0;

    while (frameCount < 60) : (frameCount += 1) {
        _ = incrementFrameCount(&timeT);
        _ = tryElapseFrameCount(&timeT);
        _ = tryElapseSeconds(&timeT);
        _ = tryElapseMinutes(&timeT);
    }
    
    try std.testing.expect(frameCount == 60);
    try std.testing.expect(timeT.frameCount == 0);
    try std.testing.expect(timeT.seconds == 1);
    try std.testing.expect(timeT.minutes == 0);
    try std.testing.expect(timeT.hours == 0);
}

test "Count Up One Minute" {
    var timeT: TimeTracker = .{
        .frameCount = 0,
        .seconds = 0,
        .minutes = 0,
        .hours = 0
    };

    var frameCount: u32 = 0;

    while (frameCount < (60 * 60)) : (frameCount += 1) {
        _ = incrementFrameCount(&timeT);
        _ = tryElapseFrameCount(&timeT);
        _ = tryElapseSeconds(&timeT);
        _ = tryElapseMinutes(&timeT);
    }
    
    try std.testing.expect(frameCount == 3600);
    try std.testing.expect(timeT.frameCount == 0);
    try std.testing.expect(timeT.seconds == 0);
    try std.testing.expect(timeT.minutes == 1);
    try std.testing.expect(timeT.hours == 0);
}

test "Count Up One Hour" {
    var timeT: TimeTracker = .{
        .frameCount = 0,
        .seconds = 0,
        .minutes = 0,
        .hours = 0
    };

    var frameCount: u32 = 0;

    while (frameCount < (60 * 60 * 60)) : (frameCount += 1) {
        _ = incrementFrameCount(&timeT);
        _ = tryElapseFrameCount(&timeT);
        _ = tryElapseSeconds(&timeT);
        _ = tryElapseMinutes(&timeT);
    }
    
    try std.testing.expect(frameCount == 216_000);
    try std.testing.expect(timeT.frameCount == 0);
    try std.testing.expect(timeT.seconds == 0);
    try std.testing.expect(timeT.minutes == 0);
    try std.testing.expect(timeT.hours == 1);
}

test "Count Down Sixty Frames" {
    var timeT: TimeTracker = .{
        .frameCount = 60,
        .seconds = 0,
        .minutes = 0,
        .hours = 0
    };

    var frameCount: u8 = 0;

    while (frameCount < 90) : (frameCount += 1) {
        _ = tryReduceHours(&timeT);
        _ = tryReduceMinutes(&timeT);
        _ = tryReduceSeconds(&timeT);
        _ = decrementFrameCount(&timeT);
    }
    
    try std.testing.expect(frameCount == 90);
    try std.testing.expect(timeT.frameCount == 0);
    try std.testing.expect(timeT.seconds == 0);
    try std.testing.expect(timeT.minutes == 0);
    try std.testing.expect(timeT.hours == 0);
}

test "Count Down One Second" {
    var timeT: TimeTracker = .{
        .frameCount = 0,
        .seconds = 1,
        .minutes = 0,
        .hours = 0
    };

    var frameCount: u8 = 0;

    while (frameCount < 90) : (frameCount += 1) {
        _ = tryReduceHours(&timeT);
        _ = tryReduceMinutes(&timeT);
        _ = tryReduceSeconds(&timeT);
        _ = decrementFrameCount(&timeT);
    }
    
    try std.testing.expect(timeT.frameCount == 0);
    try std.testing.expect(timeT.seconds == 0);
    try std.testing.expect(timeT.minutes == 0);
    try std.testing.expect(timeT.hours == 0);
}


test "Count Down One Minute" {
    var timeT: TimeTracker = .{
        .frameCount = 0,
        .seconds = 0,
        .minutes = 1,
        .hours = 0
    };

    var frameCount: u32 = 0;

    while (frameCount < ((60 * 60) + 90)) : (frameCount += 1) {
        _ = tryReduceHours(&timeT);
        _ = tryReduceMinutes(&timeT);
        _ = tryReduceSeconds(&timeT);
        _ = decrementFrameCount(&timeT);
    }
    
    try std.testing.expect(frameCount == 3690);
    try std.testing.expect(timeT.frameCount == 0);
    try std.testing.expect(timeT.seconds == 0);
    try std.testing.expect(timeT.minutes == 0);
    try std.testing.expect(timeT.hours == 0);
}

test "Count Down One Hour" {
    var timeT: TimeTracker = .{
        .frameCount = 0,
        .seconds = 0,
        .minutes = 0,
        .hours = 1
    };

    var frameCount: u32 = 0;

    while (frameCount < ((60 * 60 * 60) + 90)) : (frameCount += 1) {
        _ = tryReduceHours(&timeT);
        _ = tryReduceMinutes(&timeT);
        _ = tryReduceSeconds(&timeT);
        _ = decrementFrameCount(&timeT);
    }
    
    try std.testing.expect(frameCount == 216_090);
    try std.testing.expect(timeT.frameCount == 0);
    try std.testing.expect(timeT.seconds == 0);
    try std.testing.expect(timeT.minutes == 0);
    try std.testing.expect(timeT.hours == 0);
}