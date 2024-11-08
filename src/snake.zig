const std = @import("std");

const physics_module = @import("physics.zig");
const obstacles_module = @import("obstacles.zig");

// Possible snake loop:
//  Player presses DOWN key
//  Modify current head position by key value -1, 0
//  Copy all positions from head to tail
//  Continue moving head position down by -1, 0 until new input arrives

pub const CollisionType = enum {
    Self,
    Wall,
};

pub const SnakeCollisionMatch = struct {
    collidedWith: CollisionType,
    collided: bool,
};

pub const FoodIndexMatch = struct {
    match: bool,
    index: u32,
};

pub const SideMatch = struct {
    match: bool,
    side: Side,
};

pub const Side = enum { TOP, BOTTOM, LEFT, RIGHT, NONE };

pub const Direction = enum { UP, DOWN, LEFT, RIGHT };

pub fn directionToPoint(dir: Direction) physics_module.Point {
    switch (dir) {
        Direction.UP => {
            return .{
                .x = 0,
                .y = -1,
            };
        },
        Direction.DOWN => {
            return .{
                .x = 0,
                .y = 1,
            };
        },
        Direction.LEFT => {
            return .{
                .x = -1,
                .y = 0,
            };
        },
        Direction.RIGHT => {
            return .{
                .x = 1,
                .y = 0,
            };
        },
    }
}

pub const snakeLogicFrameTime: u8 = 8;

pub const Snake = struct {
    // Direction enum (use to calculate next head target position)
    headDir: Direction,

    // size (length of array)
    snakeSize: physics_module.IndexOfPointsArray64,

    // array of x,y integers (positions) for each body segment
    snakeBody: physics_module.PointsArray64,

    // bool to determine if the snake can grow this update
    fed: bool,

    collided: bool,

    pub fn init() Snake {
        return .{ 
            .headDir = Direction.RIGHT, 
            .snakeSize = .{ .i = 1 }, 
            .snakeBody = physics_module.PointsArray64{ .x = undefined, .y = undefined }, 
            .fed = false,
            .collided = false,
        };
    }
};

pub const Food = struct {
    // x,y integer
    position: physics_module.Point,

    // bool to determine if this food has spawned
    spawned: bool,
};

pub fn feedSnake(snakeInstance: *Snake) void {
    snakeInstance.fed = true;
}

// Add a new tail segment to a Snake. Call after updating snake positions
// Fragility Note: expects a maximum of one tail segment to be added per cycle
pub fn addSegmentToSnake(snakeInstance: *Snake) bool {
    if (snakeInstance.snakeSize.i < snakeInstance.snakeBody.x.len) {
        snakeInstance.snakeSize.i = snakeInstance.snakeSize.i + 1;
    } else {
        return false;
    }

    // Copy current tail to new tail
    snakeInstance.snakeBody.x[snakeInstance.snakeSize.i - 1] = snakeInstance.snakeBody.x[snakeInstance.snakeSize.i - 2];
    snakeInstance.snakeBody.y[snakeInstance.snakeSize.i - 1] = snakeInstance.snakeBody.y[snakeInstance.snakeSize.i - 2];

    return true;
}

// Update all points on a Snake to match given points
pub fn updateSnakePosition(snakeInstance: *Snake, aX: []const i32, aY: []const i32) void {
    for (snakeInstance.snakeBody.x[0..snakeInstance.snakeSize.i], aX[0..snakeInstance.snakeSize.i]) |*xElem, aXElem| {
        xElem.* = aXElem;
    }

    for (snakeInstance.snakeBody.y[0..snakeInstance.snakeSize.i], aY[0..snakeInstance.snakeSize.i]) |*yElem, aYElem| {
        yElem.* = aYElem;
    }
}

pub fn doesPossibleHeadDirHitNeck(snakeInstance: Snake, dir: Direction) bool {
    // Calculate next point for snake head
    const directionAsPoint = directionToPoint(dir);
    if (snakeInstance.snakeBody.x[1] == (snakeInstance.snakeBody.x[0] + directionAsPoint.x) and
        snakeInstance.snakeBody.y[1] == (snakeInstance.snakeBody.y[0] + directionAsPoint.y)
    ) {
        return true;
    }

    return false;
}

// Fragility Note: expects a minimum snake size of 2 segments
pub fn calculateSnakePositionUpdates(snakeInstance: Snake) physics_module.PointsArray64 {
    // Store positions to update in an array
    var positionsArray = physics_module.PointsArray64{ .x = undefined, .y = undefined };

    // Copy current head position to temp var
    const recordedHeadValue = physics_module.Point{ .x = snakeInstance.snakeBody.x[0], .y = snakeInstance.snakeBody.y[0] };

    // Calculate next point for snake head
    const directionAsPoint = directionToPoint(snakeInstance.headDir);

    const calculatedHeadValue = physics_module.Point{ .x = (snakeInstance.snakeBody.x[0] + directionAsPoint.x), .y = (snakeInstance.snakeBody.y[0] + directionAsPoint.y) };

    var posIndex: physics_module.IndexOfPointsArray64 = .{ .i = snakeInstance.snakeSize.i - 1 };
    while (posIndex.i > 1) : (posIndex.i -= 1) {
        positionsArray.x[posIndex.i] = snakeInstance.snakeBody.x[posIndex.i - 1];
        positionsArray.y[posIndex.i] = snakeInstance.snakeBody.y[posIndex.i - 1];
    }

    // Set calculated head value in positionsArray
    positionsArray.x[0] = calculatedHeadValue.x;
    positionsArray.y[0] = calculatedHeadValue.y;

    // Calculate position for segment that will take place of the current head position
    positionsArray.x[1] = recordedHeadValue.x;
    positionsArray.y[1] = recordedHeadValue.y;

    return positionsArray;
}

// Call on repeat to run snake logic
pub fn snakeMoveSystem(snakeInstance: *Snake) void {
    var positionsArray = calculateSnakePositionUpdates(snakeInstance.*);

    updateSnakePosition(snakeInstance, positionsArray.x[0..snakeInstance.snakeSize.i], positionsArray.y[0..snakeInstance.snakeSize.i]);

    // Try to grow snake if fed
    if (snakeInstance.fed) {
        if (addSegmentToSnake(snakeInstance)) {
            snakeInstance.fed = false;
        } else {
            // Max snakeSize reached!
        }
    }
}

pub fn snakeBodyToMapObstaclesCollisionCheck(snakeInstance: Snake, obstaclesMap: obstacles_module.ObstaclesMap) bool {
    var snakePointsIndex: physics_module.IndexOfPointsArray64 = .{ .i = 0 };
    while (snakePointsIndex.i < snakeInstance.snakeSize.i) : (snakePointsIndex.i += 1) {
        if (obstacles_module.readAllObstaclesWithCollision(
            snakeInstance.snakeBody.x[snakePointsIndex.i], 
            snakeInstance.snakeBody.y[snakePointsIndex.i], 
            obstaclesMap)
        ) {
            return true;
        }
    }
    return false;
}

// Call on repeat to check if snake has hit something game ending
pub fn snakeCollisionSystem(snakeInstance: Snake, mapBounds: []const physics_module.PointsArray64, mapLength: physics_module.IndexOfPointsArray64, obstaclesMap: obstacles_module.ObstaclesMap) SnakeCollisionMatch {
    if (snakeHeadToBodyCollisionCheck(snakeInstance, snakeInstance.snakeBody.x[0], snakeInstance.snakeBody.y[0])) {
        return .{ .collidedWith = CollisionType.Self, .collided = true };
    }

    if (snakeHeadToMapBoundsCollisionCheck(snakeInstance.snakeBody.x[0], snakeInstance.snakeBody.y[0], mapBounds, mapLength)) {
        return .{ .collidedWith = CollisionType.Wall, .collided = true };
    }

    if (snakeBodyToMapObstaclesCollisionCheck(snakeInstance, obstaclesMap)) {
        return .{ .collidedWith = CollisionType.Wall, .collided = true };
    }

    return .{ .collidedWith = CollisionType.Self, .collided = false };
}

// Return index into foodArray
pub fn snakeFeedingSystem(snakeInstance: *Snake, foodArray: []Food) FoodIndexMatch {
    var foodIndex: u32 = 0;
    for (foodArray) |foodElem| {
        if ((foodElem.position.x == snakeInstance.snakeBody.x[0]) and (foodElem.position.y == snakeInstance.snakeBody.y[0])) {
            // Food found at snake head
            feedSnake(snakeInstance);
            return .{ .match = true, .index = foodIndex };
        }
        foodIndex = foodIndex + 1;
        // Skip food beyond index 0 for now:
        if (foodIndex == 1) {
            return .{ .match = false, .index = 0 };
        }
    }

    return .{ .match = false, .index = 0 };
}

// Call to change the direction the snake will travel
pub fn snakeInputDirection(snakeInstance: *Snake, dir: Direction) void {
    snakeInstance.headDir = dir;
}

// Pass in head position to check if it collides with any body part
pub fn snakeHeadToBodyCollisionCheck(snakeInstance: Snake, headX: i32, headY: i32) bool {
    var posIndex: physics_module.IndexOfPointsArray64 = .{ .i = snakeInstance.snakeSize.i - 1 };
    while (posIndex.i > 1) : (posIndex.i -= 1) {
        if ((snakeInstance.snakeBody.x[posIndex.i] == headX) and (snakeInstance.snakeBody.y[posIndex.i] == headY)) {
            return true;
        }
    }

    return false;
}

// Pass in head position to check if it collides with map bounds
pub fn snakeHeadToMapBoundsCollisionCheck(headX: i32, headY: i32, mapBounds: []const physics_module.PointsArray64, mapLength: physics_module.IndexOfPointsArray64) bool {
    var mapBoundsIndex: physics_module.IndexOfPointsArray64 = .{ .i = 0 };
    while (mapBoundsIndex.i <= 3) : (mapBoundsIndex.i += 1) {
        const pointFound: physics_module.PointMatch = physics_module.findPointInPointsArray64(headX, headY, mapBounds[mapBoundsIndex.i], .{ .i = 0 }, mapLength);
        if (pointFound.match) {
            return true;
        }
    }

    return false;
}

pub fn foodArrayToPointsArray(foodArray: []Food) physics_module.PointsArray4 {
    var pointsArray: physics_module.PointsArray4 = undefined;
    var pointsIndex: physics_module.IndexOfPointsArray4 = .{ .i = 0};
    for (foodArray) |food| {
        pointsArray.x[pointsIndex.i] = food.position.x;
        pointsArray.y[pointsIndex.i] = food.position.y;
        pointsIndex.i  += 1;
    }
    return pointsArray;
}

pub fn shoveFoodDownFoodArray(foodArray: []Food) void {
    var foodArrayIndex: u8 = 0;
    while (foodArrayIndex < foodArray.len - 1) : (foodArrayIndex += 1) {
        foodArray[foodArrayIndex + 1].position.x = foodArray[foodArrayIndex].position.x;
        foodArray[foodArrayIndex + 1].position.y = foodArray[foodArrayIndex].position.y;
    }
}

// Call on repeat to run food logic for all food
pub fn foodSpawnSystem(foodArray: []Food, maxFood: u8, mapBoundXBegin: i32, mapBoundXEnd: i32, mapBoundYBegin: i32, mapBoundYEnd: i32, randomNumberGenerator: std.Random) void {
    var foodIndex: u32 = 0;
    while (foodIndex < foodArray.len and foodIndex < maxFood) : (foodIndex += 1) {
        if (foodArray[foodIndex].spawned) {} else {
            shoveFoodDownFoodArray(foodArray);

            spawnFood(&foodArray[foodIndex], mapBoundXBegin, mapBoundXEnd, mapBoundYBegin, mapBoundYEnd, randomNumberGenerator);
            foodArray[foodIndex].spawned = true;
        }
    }
}

// Spawn food at a random location within given map bounds
pub fn spawnFood(foodInstance: *Food, mapBoundXBegin: i32, mapBoundXEnd: i32, mapBoundYBegin: i32, mapBoundYEnd: i32, randomNumberGenerator: std.Random) void {
    foodInstance.position = physics_module.getRandomPointInRange(mapBoundXBegin, mapBoundXEnd, mapBoundYBegin, mapBoundYEnd, randomNumberGenerator);
}

// Call on repeat
// Pass in an array of indexes into foodArray to despawn
pub fn foodDespawnSystem(foodArray: []Food, indexOfFoodToDespawnArray: []const u32) void {
    var foodIndex: u32 = 0;
    while (foodIndex < indexOfFoodToDespawnArray.len) : (foodIndex += 1) {
        despawnFood(&foodArray[indexOfFoodToDespawnArray[foodIndex]]);
    }
}

pub fn despawnFood(foodInstance: *Food) void {
    foodInstance.spawned = false;
    foodInstance.position = .{ .x = 0, .y = 0 };
}