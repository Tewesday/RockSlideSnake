// Defines the rules of the snake game

const gamestate_module = @import("gamestate.zig");
const snake_module = @import("snake.zig");
const physics_module = @import("physics.zig");
const obstacles_module = @import("obstacles.zig");


pub const VictoryCondition = enum {
    ReachSize,  // Reach a snake size
    Survival,   // Get food before time runs out
};

pub const VictoryFlags = packed struct {
    ReachSize: bool,
    Survival:  bool,
};

pub const DefeatCondition = enum {
    Collided,  // Snake collided
    Time,      // Snake ran out of time
};

pub const DefeatFlags = packed struct {
    Collided: bool,
    Time:     bool,
};

pub const DifficultyEnum = enum {
    Easy,
    Normal,
    Hard,
};

pub const Difficulty = struct {
    currentDiff: DifficultyEnum,
};

pub const SnakeRulesState = struct {
    matchPhase:           gamestate_module.MatchPhase,
    activeVictoryFlags:   VictoryFlags,
    activeDefeatFlags:    DefeatFlags,
    sizeGoal:             physics_module.IndexOfPointsArray64,
    mapBoundsBegin:       i32,
    mapBoundsEnd:         i32,
    snakeTimeRules:       SnakeTimeRulesState,
};

pub const SnakeTimeRulesState = struct {
    timeSeconds: u8,
    timeMinutes: u8,
    timeHours:   u32,
};

// Easy difficulty default template
pub const snakeRulesEasy: SnakeRulesState = .{
    .matchPhase = .{ .currentPhase = gamestate_module.MatchPhaseEnum.Active },
    .activeVictoryFlags =  .{ .ReachSize = true, .Survival = false },
    .activeDefeatFlags =  .{ .Collided = true, .Time = true },
    .sizeGoal = .{ .i = 10 },
    .mapBoundsBegin = 0,
    .mapBoundsEnd = 40,
    .snakeTimeRules = snakeTimeRulesEasy,
};

pub const snakeTimeRulesEasy = .{
    .timeSeconds = 20,
    .timeMinutes = 0,
    .timeHours =   0,
};

// Normal difficulty default template
pub const snakeRulesNormal: SnakeRulesState = .{
    .matchPhase = .{ .currentPhase = gamestate_module.MatchPhaseEnum.Active },
    .activeVictoryFlags =  .{ .ReachSize = true, .Survival = false },
    .activeDefeatFlags =  .{ .Collided = true, .Time = true },
    .sizeGoal = .{ .i = 20 },
    .mapBoundsBegin = 0,
    .mapBoundsEnd = 40,
    .snakeTimeRules = snakeTimeRulesEasy,
};

pub const snakeTimeRulesNormal = .{
    .timeSeconds = 15,
    .timeMinutes = 0,
    .timeHours =   0,
};

// Hard difficulty default template
pub const snakeRulesHard: SnakeRulesState = .{
    .matchPhase = .{ .currentPhase = gamestate_module.MatchPhaseEnum.Active },
    .activeVictoryFlags =  .{ .ReachSize = true, .Survival = false },
    .activeDefeatFlags =  .{ .Collided = true, .Time = true },
    .sizeGoal = .{ .i = 30 },
    .mapBoundsBegin = 0,
    .mapBoundsEnd = 40,
    .snakeTimeRules = snakeTimeRulesEasy,
};

pub const snakeTimeRulesHard = .{
    .timeSeconds = 12,
    .timeMinutes = 0,
    .timeHours =   0,
};

pub fn determineSnakeReachedSizeGoal(snakeInstance: snake_module.Snake, snakeRulesState: SnakeRulesState) bool {
    return snakeInstance.snakeSize.i == snakeRulesState.sizeGoal.i;
}

pub fn determineSnakeReachedTimeLimit(snakeRulesState: SnakeRulesState, currentTime: SnakeTimeRulesState) bool {
    if ((snakeRulesState.snakeTimeRules.timeSeconds == currentTime.timeSeconds) and 
        (snakeRulesState.snakeTimeRules.timeMinutes == currentTime.timeMinutes) and
        (snakeRulesState.snakeTimeRules.timeHours == currentTime.timeHours)) {
            return true;
    }
    return false;
}

pub fn tryHasSnakeWon(snakeInstance: snake_module.Snake, snakeRulesState: *SnakeRulesState) bool {
    
    if (snakeRulesState.activeVictoryFlags.ReachSize) {
        if (determineSnakeReachedSizeGoal(snakeInstance, snakeRulesState.*)) {
            snakeRulesState.matchPhase.currentPhase = gamestate_module.MatchPhaseEnum.Victory;
            return true;
        }
    }
    
    return false;
}

pub fn tryHasSnakeLost(
    snakeInstance: snake_module.Snake, 
    snakeRulesState: *SnakeRulesState, 
    mapBounds: []const physics_module.PointsArray64, 
    mapLength: physics_module.IndexOfPointsArray64,
    currentTime: SnakeTimeRulesState,
    obstaclesMap: obstacles_module.ObstaclesMap,
) bool {
    
    if (snakeRulesState.activeDefeatFlags.Collided) {
        const checkCollision = snake_module.snakeCollisionSystem(snakeInstance, mapBounds, mapLength, obstaclesMap);
        if (checkCollision.collided) {
            snakeRulesState.matchPhase.currentPhase = gamestate_module.MatchPhaseEnum.Defeat;
            return true;
        }
    }

    if (snakeRulesState.activeDefeatFlags.Time) {
        if (determineSnakeReachedTimeLimit(snakeRulesState.*, currentTime)) {
            snakeRulesState.matchPhase.currentPhase = gamestate_module.MatchPhaseEnum.Defeat;
            return true;
        }
    }
    
    return false;
}

pub fn changeSnakeDifficulty(snakeRules: *SnakeRulesState, diffSetting: DifficultyEnum) void {
    if (diffSetting == DifficultyEnum.Easy) {
        snakeRules.sizeGoal = snakeRulesEasy.sizeGoal;
        snakeRules.snakeTimeRules = snakeTimeRulesEasy;
    }
    else if (diffSetting == DifficultyEnum.Normal) {
        snakeRules.sizeGoal = snakeRulesNormal.sizeGoal;
        snakeRules.snakeTimeRules = snakeTimeRulesNormal;
    }
    else if (diffSetting == DifficultyEnum.Hard) {
        snakeRules.sizeGoal = snakeRulesHard.sizeGoal;
        snakeRules.snakeTimeRules = snakeTimeRulesHard;
    }
}