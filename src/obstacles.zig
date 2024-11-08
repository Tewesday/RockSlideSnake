const std = @import("std");

const physics_module = @import("physics.zig");
const geometry_module = @import("geometry.zig");

const ObstacleLength: u8 = 4;

pub const obstacleLogicFrameTime: u8 = 16;

pub const ObstacleTypeEnum = enum {
    T,
    L,
    J,
    Z,
    S,
    O,
    I,
};

pub const ObstaclesMap = struct {
    // Obstacle points
    obstacles: physics_module.PointsArray64,

    // An obstacle map can only hold 64 / 4 (16) obstacles
    // Each bool determines if a slot is open
    availableSlots: [16]bool,

    pub fn init() ObstaclesMap {
        var obs: ObstaclesMap = undefined;
        obs.obstacles = undefined;
        obs.availableSlots = undefined;
        @memset(&obs.obstacles.x, 0);
        @memset(&obs.obstacles.y, 0);
        @memset(&obs.availableSlots, true);
        return obs;
    }
};

pub fn convertObstaclesIndexToSlot(obstaclesIndex: physics_module.IndexOfPointsArray64) u8 {
    return obstaclesIndex.i / ObstacleLength;
}

pub fn convertSlotToObstaclesIndex(slot: u8) physics_module.IndexOfPointsArray64 {
    return .{ .i = slot * ObstacleLength };
}

pub fn deleteObstaclesBeyondMapBoundsBottom(obstaclesMap: *ObstaclesMap, mapBounds: physics_module.PointsArray64) void {
    const bottomY = mapBounds.y[0];
    var obstaclesIndex: physics_module.IndexOfPointsArray64 = .{ .i = 0 };
    // Every obstacle is 4 points wide
    // Cheat here and calculate if top most point of obstacle is beyond bottom bound
    while(obstaclesIndex.i < 64) : (obstaclesIndex.i += ObstacleLength) {
        if (obstaclesMap.obstacles.y[obstaclesIndex.i] > bottomY) {
            // Obstacle can be removed
            var currentObstacleIndex = obstaclesIndex;
            while (currentObstacleIndex.i < ObstacleLength) : (currentObstacleIndex.i += 1) {
                obstaclesMap.obstacles.x[currentObstacleIndex.i] = 0;
                obstaclesMap.obstacles.y[currentObstacleIndex.i] = 0;
            }
            // Make slot available
            obstaclesMap.availableSlots[convertObstaclesIndexToSlot(obstaclesIndex)] = true;
        }
    }
}

pub fn insertObstacleIntoPointsArray64(obstaclePoints: physics_module.PointsArray4, insertionIndexStart: physics_module.IndexOfPointsArray64, points64: *physics_module.PointsArray64) void {
    var pointsIndex = insertionIndexStart;
    var obstacleIndex: physics_module.IndexOfPointsArray4 = .{ .i = 0 };
    while (obstacleIndex.i < ObstacleLength) : (obstacleIndex.i += 1) {
        points64.x[pointsIndex.i] = obstaclePoints.x[obstacleIndex.i];
        points64.y[pointsIndex.i] = obstaclePoints.y[obstacleIndex.i];
        pointsIndex.i += 1;
    }
}

pub const SlotMatch = struct {
    slotIndex: u8,
    available: bool,
};

pub fn findAvailableSlot(obstaclesMap: ObstaclesMap) SlotMatch {
    var slotIndex: u8 = 0;
    while (slotIndex < 16) : (slotIndex += 1) {
        if (obstaclesMap.availableSlots[slotIndex]) {
            return .{ .slotIndex = slotIndex, .available = true };
        }
    }
    return .{ .slotIndex = 0, .available = false };
}

pub fn findNextUnavailableSlot(obstaclesMap: ObstaclesMap, startingSlot: u8) SlotMatch {
    var slotIndex: u8 = startingSlot;
    while (slotIndex < 16) : (slotIndex += 1) {
        if (obstaclesMap.availableSlots[slotIndex] == false) {
            return .{ .slotIndex = slotIndex, .available = false };
        }
    }
    return .{ .slotIndex = 0, .available = true };
}

pub fn tryInsertObstacleIntoObstaclesMap(obstaclePoints: physics_module.PointsArray4, obstaclesMap: *ObstaclesMap) bool {
    const slotMatch: SlotMatch = findAvailableSlot(obstaclesMap.*);
    if (slotMatch.available) {
        insertObstacleIntoPointsArray64(obstaclePoints, convertSlotToObstaclesIndex(slotMatch.slotIndex), &obstaclesMap.obstacles);
        obstaclesMap.availableSlots[slotMatch.slotIndex] = false;
        return true;
    }
    
    return false;
}

// Calculate next y + 1 position for each obstacle
pub fn calculateObstaclesPositionUpdates(obstaclesMap: ObstaclesMap) physics_module.PointsArray64 {
    var obstaclesIndex: physics_module.IndexOfPointsArray64  = .{ .i = 0 };
    var obstaclesPositions: physics_module.PointsArray64 = undefined;
    while (obstaclesIndex.i < 64) : (obstaclesIndex.i += 1) {
        obstaclesPositions.x[obstaclesIndex.i] = (obstaclesMap.obstacles.x[obstaclesIndex.i]);
        obstaclesPositions.y[obstaclesIndex.i] = (obstaclesMap.obstacles.y[obstaclesIndex.i] + 1);
    }
    return obstaclesPositions;
}

pub fn obstaclesSpawnSystem(obstaclesMap: *ObstaclesMap, numberOfObstacles: u8, rng: std.Random, rectToAvoid: geometry_module.Rectangle(i32), rectToAvoid2: geometry_module.Rectangle(i32)) void {
    var obstacleCount: u8 = 0;
    while (obstacleCount < numberOfObstacles) : (obstacleCount += 1) {
        var obstacle = createObstacleAtXY(rng.enumValue(ObstacleTypeEnum), rng);

        // Ensure spawned obstacle avoids given points
        const maxAttempts: u8 = 60;
        var attempts: u8 = 0;
        while ((doesObstacleSpawnInRect(obstacle, rectToAvoid) or
            doesObstacleSpawnInRect(obstacle, rectToAvoid2)) and 
            attempts < maxAttempts) 
        {
            obstacle = createObstacleAtXY(rng.enumValue(ObstacleTypeEnum), rng);
            attempts += 1;
        }
        _ = tryInsertObstacleIntoObstaclesMap(obstacle, obstaclesMap);
    }
}

pub fn doesObstacleSpawnNearPoint(obstacle: physics_module.PointsArray4, point: physics_module.Point) bool {
    var obstaclePointIndex: physics_module.IndexOfPointsArray4 = .{ .i = 0 };
    while (obstaclePointIndex.i < 1) : (obstaclePointIndex.i += 1) {
        const val = physics_module.getSqrtDistanceBetweenPoints(
            .{.x = obstacle.x[obstaclePointIndex.i], .y = obstacle.x[obstaclePointIndex.i]},
             point
        );
        if (val < 3) {
            return true;
        }
    }
    
    return false;
}

pub fn doesObstacleSpawnInRegion(obstacle: physics_module.PointsArray4, region: physics_module.PointsArray15) bool {
    var obstaclePointIndex: physics_module.IndexOfPointsArray4 = .{ .i = 0 };
    while (obstaclePointIndex.i < 1) : (obstaclePointIndex.i += 1) {
        const pointMatch = physics_module.findPointInPointsArray15(obstacle.x[obstaclePointIndex.i], obstacle.y[obstaclePointIndex.i], region, .{ .i = 0 }, .{ .i = 8 });
        if (pointMatch.match) {
            return true;
        }
    }
    return false;
}

pub fn doesObstacleSpawnInRect(obstacle: physics_module.PointsArray4, rect: geometry_module.Rectangle(i32)) bool {
    var obstaclePointIndex: physics_module.IndexOfPointsArray4 = .{ .i = 0 };
    while (obstaclePointIndex.i < 1) : (obstaclePointIndex.i += 1) {
        if (rect.contains(obstacle.x[obstaclePointIndex.i], obstacle.y[obstaclePointIndex.i])) {
            return true;
        }
    }
    return false;
}

pub fn obstaclesDespawnSystem(obstaclesMap: *ObstaclesMap, mapBounds: physics_module.PointsArray64) void {
    var obstacleCount: u8 = 0;
    while (obstacleCount < obstaclesMap.availableSlots.len) : (obstacleCount += 1) {
        deleteObstaclesBeyondMapBoundsBottom(obstaclesMap, mapBounds);
    }
}

// Move each obstacle
pub fn obstaclesMoveSystem(obstaclesMap: *ObstaclesMap) void {
    obstaclesMap.obstacles = calculateObstaclesPositionUpdates(obstaclesMap.*);
}

pub fn readAllObstaclesWithFunc(func: *const fn (obstacleX: i32, obstacleY: i32) void, obstaclesMap: ObstaclesMap) void {
    var slotIndex: u8 = 0;
    var slotMatch = findNextUnavailableSlot(obstaclesMap, slotIndex);
    while (slotMatch.available == false) {
        const obstacleIndexBegin = convertSlotToObstaclesIndex(slotMatch.slotIndex);
        var obstacleIndex = obstacleIndexBegin;
        while (obstacleIndex.i < obstacleIndexBegin.i + ObstacleLength) : (obstacleIndex.i += 1) {
            func(obstaclesMap.obstacles.x[obstacleIndex.i], obstaclesMap.obstacles.y[obstacleIndex.i]);
        }
        slotIndex = slotMatch.slotIndex + 1;
        slotMatch = findNextUnavailableSlot(obstaclesMap, slotIndex);
    }   
}

pub fn readAllObstaclesWithCollision(obstacleX: i32, obstacleY: i32, obstaclesMap: ObstaclesMap) bool {
    var obstaclesIndex: physics_module.IndexOfPointsArray64 = .{ .i = 0 };
    while (obstaclesIndex.i < 64) : (obstaclesIndex.i += 1) {
        if (obstaclesMap.obstacles.x[obstaclesIndex.i] == obstacleX and obstaclesMap.obstacles.y[obstaclesIndex.i] == obstacleY) {
            return true;
        }
    }
    return false;
}

pub fn createObstacleAtXY(obstacle: ObstacleTypeEnum, rng: std.Random) physics_module.PointsArray4 {
    // Get a random starting point
    const startPoint = physics_module.getRandomPointInRange(2, 39, 2, 4, rng);

    var obstaclePoints: physics_module.PointsArray4 = undefined;
    @memset(&obstaclePoints.x, 0);
    @memset(&obstaclePoints.y, 0);
    // Calculate points in shape of Obstacle from starting point
    switch (obstacle) {
        // From top to bottom, left to right
        ObstacleTypeEnum.T => {
            obstaclePoints.x[0] = startPoint.x;
            obstaclePoints.y[0] = startPoint.y;

            obstaclePoints.x[1] = startPoint.x + 1;
            obstaclePoints.y[1] = startPoint.y;

            obstaclePoints.x[2] = startPoint.x + 2;
            obstaclePoints.y[2] = startPoint.y;

            obstaclePoints.x[3] = startPoint.x + 1;
            obstaclePoints.y[3] = startPoint.y + 1;
        },
        ObstacleTypeEnum.L => {
            obstaclePoints.x[0] = startPoint.x;
            obstaclePoints.y[0] = startPoint.y;

            obstaclePoints.x[1] = startPoint.x;
            obstaclePoints.y[1] = startPoint.y + 1;

            obstaclePoints.x[2] = startPoint.x;
            obstaclePoints.y[2] = startPoint.y + 2;

            obstaclePoints.x[3] = startPoint.x + 1;
            obstaclePoints.y[3] = startPoint.y + 2;
        },
        ObstacleTypeEnum.J => {
            obstaclePoints.x[0] = startPoint.x;
            obstaclePoints.y[0] = startPoint.y;

            obstaclePoints.x[1] = startPoint.x;
            obstaclePoints.y[1] = startPoint.y + 1;

            obstaclePoints.x[2] = startPoint.x - 1;
            obstaclePoints.y[2] = startPoint.y + 2;

            obstaclePoints.x[3] = startPoint.x;
            obstaclePoints.y[3] = startPoint.y + 2;
        },
        ObstacleTypeEnum.Z => {
            obstaclePoints.x[0] = startPoint.x;
            obstaclePoints.y[0] = startPoint.y;

            obstaclePoints.x[1] = startPoint.x + 1;
            obstaclePoints.y[1] = startPoint.y;

            obstaclePoints.x[2] = startPoint.x + 1;
            obstaclePoints.y[2] = startPoint.y + 1;

            obstaclePoints.x[3] = startPoint.x + 2;
            obstaclePoints.y[3] = startPoint.y + 1;
        },
        ObstacleTypeEnum.S => {
            obstaclePoints.x[0] = startPoint.x;
            obstaclePoints.y[0] = startPoint.y;

            obstaclePoints.x[1] = startPoint.x + 1;
            obstaclePoints.y[1] = startPoint.y;

            obstaclePoints.x[2] = startPoint.x - 1;
            obstaclePoints.y[2] = startPoint.y + 1;

            obstaclePoints.x[3] = startPoint.x;
            obstaclePoints.y[3] = startPoint.y + 1;
        },
        ObstacleTypeEnum.O => {
            obstaclePoints.x[0] = startPoint.x;
            obstaclePoints.y[0] = startPoint.y;

            obstaclePoints.x[1] = startPoint.x + 1;
            obstaclePoints.y[1] = startPoint.y;

            obstaclePoints.x[2] = startPoint.x;
            obstaclePoints.y[2] = startPoint.y + 1;

            obstaclePoints.x[3] = startPoint.x + 1;
            obstaclePoints.y[3] = startPoint.y + 1;
        },
        ObstacleTypeEnum.I => {
            obstaclePoints.x[0] = startPoint.x;
            obstaclePoints.y[0] = startPoint.y;

            obstaclePoints.x[1] = startPoint.x;
            obstaclePoints.y[1] = startPoint.y + 1;

            obstaclePoints.x[2] = startPoint.x;
            obstaclePoints.y[2] = startPoint.y + 2;

            obstaclePoints.x[3] = startPoint.x;
            obstaclePoints.y[3] = startPoint.y + 3;
        },
    }
    return obstaclePoints;
}