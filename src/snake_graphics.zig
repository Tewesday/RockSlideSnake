const snake_module = @import("snake.zig");
const wasm4_module = @import("wasm4.zig");
const physics_module = @import("physics.zig");

// Draw the snake segments as rectangles
pub fn drawSnakeAsRects(snakeInstance: snake_module.Snake, snakeWidth: u8) void {
    const colorStore = wasm4_module.DRAW_COLORS.*;
    wasm4_module.DRAW_COLORS.* = 0x0021;

    var snakeIndex: physics_module.IndexOfPointsArray64 = .{ .i = 0 };
    while (snakeIndex.i < snakeInstance.snakeSize.i) : (snakeIndex.i += 1) {
        wasm4_module.rect(snakeInstance.snakeBody.x[snakeIndex.i] * snakeWidth, snakeInstance.snakeBody.y[snakeIndex.i] * snakeWidth, 1 * snakeWidth, 1 * snakeWidth);
    }
    wasm4_module.DRAW_COLORS.* = colorStore;
}

pub fn drawFoodAsRect(foodArray: []const snake_module.Food, foodWidth: u8) void {
    const colorStore = wasm4_module.DRAW_COLORS.*;
    wasm4_module.DRAW_COLORS.* = 0x0021;

    var foodIndex: u32 = 0;
    while (foodIndex < foodArray.len) : (foodIndex += 1) {
        // Skip food beyond index 0 for now
        if (foodIndex == 1) {
            break;   
        }

        // Only render food that has spawned
        if (foodArray[foodIndex].spawned) {
            wasm4_module.rect(foodArray[foodIndex].position.x * foodWidth, foodArray[foodIndex].position.y * foodWidth, 1 * foodWidth, 1 * foodWidth);
        }
    }

    wasm4_module.DRAW_COLORS.* = colorStore;
}

// Draw a wall as rectangles (from PointsArray64)
pub fn drawWallAsRects(wall: physics_module.PointsArray64, wallLength: physics_module.IndexOfPointsArray64, wallWidth: u8) void {
    const colorStore = wasm4_module.DRAW_COLORS.*;
    wasm4_module.DRAW_COLORS.* = 0x0001;

    var wallIndex: physics_module.IndexOfPointsArray64 = .{ .i = 0 };
    while (wallIndex.i < wallLength.i) : (wallIndex.i += 1) {
        wasm4_module.rect(wall.x[wallIndex.i] * wallWidth, wall.y[wallIndex.i] * wallWidth, 1 * wallWidth, 1 * wallWidth);
    }

    wasm4_module.DRAW_COLORS.* = colorStore;
}

// Draw all MapBounds as walls
pub fn drawMapBoundsAsWalls(mapBounds: []const physics_module.PointsArray64, mapBoundLength: physics_module.IndexOfPointsArray64, wallWidth: u8) void {
    const colorStore = wasm4_module.DRAW_COLORS.*;
    wasm4_module.DRAW_COLORS.* = 0x0001;

    for (mapBounds) |mapBound| {
        drawWallAsRects(mapBound, mapBoundLength, wallWidth);
    }

    wasm4_module.DRAW_COLORS.* = colorStore;
}