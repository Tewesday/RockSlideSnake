const obstacles_module = @import("obstacles.zig");
const wasm4_module = @import("wasm4.zig");


pub fn drawObstaclesMap(obstaclesMap : obstacles_module.ObstaclesMap, obstacleBlockWidth: u8) void {
    const colorStore = wasm4_module.DRAW_COLORS.*;
    wasm4_module.DRAW_COLORS.* = 0x0001;

    _ = obstacleBlockWidth;
    obstacles_module.readAllObstaclesWithFunc(drawObstaclePiece, obstaclesMap);

    wasm4_module.DRAW_COLORS.* = colorStore;
}

pub fn drawObstaclePiece(obstacleX: i32, obstacleY: i32) void {
    const obstacleBlockWidth = 4;
    wasm4_module.rect(obstacleX * obstacleBlockWidth, obstacleY * obstacleBlockWidth, 1 * obstacleBlockWidth, 1 * obstacleBlockWidth); 
}