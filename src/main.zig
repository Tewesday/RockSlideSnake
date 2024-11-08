const std = @import("std");

const wasm4_module = @import("wasm4.zig");
const graphics_util_module = @import("graphics_util.zig");
const physics_module = @import("physics.zig");
const snake_module = @import("snake.zig");
const snake_rules_module = @import("snake_rules.zig");
const snake_graphics_module = @import("snake_graphics.zig");
const snake_audioModule = @import("snake_audio.zig");
const gamestate_module = @import("gamestate.zig");
const palettes_module = @import("palettes.zig");
const timer_module = @import("timer.zig");
const audio_util_module = @import("audio_util.zig");
const obstacles_module = @import("obstacles.zig");
const obstacle_graphics_module = @import("obstacles_graphics.zig");
const obstacles_audio_module = @import("obstacles_audio.zig");
const game_ui_module = @import("game_ui.zig");
const geometry_module = @import("geometry.zig");
const math_util_module = @import("math_util.zig");
const datastructs_module = @import("datastructs.zig");

// TODO:
// Gameplay:
    // Input buffer cleared on every second sim step?
// Framework:
    // Rename modules to x_y_module
    // Clean up imports (not all need wasm4_module trace anymore)
// Cleanup:
    // What needs to be global here vs in a game state struct


var gameStartTime: timer_module.TimeTracker = .{
    .frameCount = gameStartTimeDefault.frameCount,
    .seconds = gameStartTimeDefault.seconds,
    .minutes = gameStartTimeDefault.minutes,
    .hours = gameStartTimeDefault.hours,
};

pub const gameStartTimeDefault : timer_module.TimeTracker = .{
    .frameCount = 0,
    .seconds = 4,
    .minutes = 0,
    .hours = 0,
};

var fixedAudioBuffer: datastructs_module.FixedArrayRingBuffer(audio_util_module.Sound) = undefined;

var trackAudioQueueTime: timer_module.TimeTracker = .{
    .frameCount = 0,
    .seconds = 0,
    .minutes = 0,
    .hours = 0,
};

var fixedAudioBuffer2: datastructs_module.FixedArrayRingBuffer(audio_util_module.Sound) = undefined;

var gameStartTrackAudioQueueTime: timer_module.TimeTracker = .{
    .frameCount = gameStartTrackAudioQueueTimeDefault.frameCount,
    .seconds = 0,
    .minutes = 0,
    .hours = 0,
};

pub const gameStartTrackAudioQueueTimeDefault : timer_module.TimeTracker = .{
    .frameCount = 59,
    .seconds = 0,
    .minutes = 0,
    .hours = 0,
};

var gameStartAudioQueue: audio_util_module.AudioRingBuffer = undefined;

var victoryAudioQueue: audio_util_module.AudioRingBuffer = undefined;

var trackTimePassed: timer_module.TimeTracker = .{
    .frameCount = 0,
    .seconds = 0,
    .minutes = 0,
    .hours = 0,
};

var trackTimeCountdown: timer_module.TimeTracker = .{
    .frameCount = 0,
    .seconds = 0,
    .minutes = 0,
    .hours = 0,
};

var trackObstacleSpawnTime: timer_module.TimeTracker = .{
    .frameCount = 0,
    .seconds = 4,
    .minutes = 0,
    .hours = 0,
};

const obstacleSpawnTimeDefault = .{
    .frameCount = 20,
    .timeSeconds = 1,
    .timeMinutes = 0,
    .timeHours = 0,
};

const snakeTimeRulesDefault: snake_rules_module.SnakeTimeRulesState = .{
    .timeSeconds = 20,
    .timeMinutes = 0,
    .timeHours = 0,
};

var snakeGameState: snake_rules_module.SnakeRulesState = .{
    .matchPhase = .{ .currentPhase = gamestate_module.MatchPhaseEnum.Starting },
    .activeVictoryFlags =  .{ .ReachSize = true, .Survival = false },
    .activeDefeatFlags =  .{ .Collided = true, .Time = true },
    .sizeGoal = .{ .i = 10 },
    .mapBoundsBegin = 0,
    .mapBoundsEnd = 40,
    .snakeTimeRules = snakeTimeRulesDefault,
};

var snakeFood: [2]snake_module.Food = .{.{ .position = .{ .x = 0, .y = 0 }, .spawned = false }, .{ .position = .{ .x = 0, .y = 0 }, .spawned = true }};

var regionFoodIsIn: snake_module.RegionMatch = .{
    .match = false,
    .index = 0,
};

var playerSnake: snake_module.Snake = snake_module.Snake.init();

var prevInputState: u8 = 0;

var totalFrameCount: u32 = 0;
var frameCount: u32 = 0;
var obstaclesFrameCount: u32 = 0;

// Each logic step, subtract 1 Y from obstacles to move them down the screen
// Fill with obstacles randomly placed around the map
var mapObstacles: obstacles_module.ObstaclesMap = undefined;

var rectAroundFood: geometry_module.Rectangle(i32) = geometry_module.Rectangle(i32).initCenter(0, 0, 15, 15);
var rectAroundFood2: geometry_module.Rectangle(i32) = geometry_module.Rectangle(i32).initCenter(0, 0, 15, 15);

const mapBounds: [4]physics_module.PointsArray64 = .{
    mapBoundsTop,
    mapBoundsBottom,
    mapBoundsLeft,
    mapBoundsRight,
};

const mapBoundsTop: physics_module.PointsArray64 = .{
    .x = .{ 
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
        11, 12, 13, 14, 15, 16, 17, 18, 19, 
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
        50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
        60, 61, 62, 63 
        },

    .y = .{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 1-10
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 11-20
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 21-30
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 31-40
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 41-50
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 51-60
        0, 0, 0, 0, // 61-64
    },
};

const mapBoundsBottom: physics_module.PointsArray64 = .{
    .x = .{ 
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 
        10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
        50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
        60, 61, 62, 63 
    },

    .y = .{
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 1-10
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 11-20
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 21-30
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 31-40
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 41-50
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 51-60
        39, 39, 39, 39, // 61-64
    },
};

const mapBoundsLeft: physics_module.PointsArray64 = .{
    .x = .{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 1-10
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 11-20
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 21-30
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 31-40
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 41-50
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 51-60
        0, 0, 0, 0, // 61-64
    },

    .y = .{ 
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 
        10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
        50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
        60, 61, 62, 63 
    },
};

const mapBoundsRight: physics_module.PointsArray64 = .{
    .x = .{
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 1-10
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 11-20
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 21-30
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 31-40
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 41-50
        39, 39, 39, 39, 39, 39, 39, 39, 39, 39, // 51-60
        39, 39, 39, 39, // 61-64
    },

    .y = .{ 
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 
        10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
        50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
        60, 61, 62, 63 
    },
};

var prng: std.Random.DefaultPrng = undefined;
var randomNumberGenerator: std.Random = undefined;

var difficultyUISelection: snake_rules_module.Difficulty = .{ .currentDiff = snake_rules_module.DifficultyEnum.Easy };

pub fn spawnSnake() void {
    playerSnake = snake_module.Snake.init();
    playerSnake.snakeSize = .{ .i = 2 };
    const startPoint = physics_module.getRandomPointInRange(8, 28, 8, 34, randomNumberGenerator);

    const startPosXs = [2]i32{ startPoint.x + 1, startPoint.y };
    const startPosYs = [2]i32{ startPoint.x, startPoint.y };
    snake_module.updateSnakePosition(&playerSnake, startPosXs[0..2], startPosYs[0..2]);
}

pub fn resetGame() void {
    timer_module.setTimeValuesMinutes(
        &trackTimeCountdown,
        0,
        snakeGameState.snakeTimeRules.timeSeconds,
        snakeGameState.snakeTimeRules.timeMinutes
    );

    timer_module.setTimeValuesZero(&trackTimePassed);

    // Reset snake
    spawnSnake();

    // Reset food
    snakeFood[0].spawned = false;

    // Reset obstacles
    mapObstacles = obstacles_module.ObstaclesMap.init();

    snake_audioModule.playGameStartSound(&gameStartAudioQueue);

    snakeGameState.matchPhase.currentPhase = gamestate_module.MatchPhaseEnum.Starting;
}

pub fn startAudioQueues() void {
    const audioBuffer: [64]audio_util_module.Sound = undefined;

    fixedAudioBuffer = .{
            .arrayT = audioBuffer,
            .usedLen = 0,
            .readIndex = 0,
            .writeIndex = 0,
    };

    const audioBuffer2: [64]audio_util_module.Sound = undefined;

    fixedAudioBuffer2 = .{
            .arrayT = audioBuffer2,
            .usedLen = 0,
            .readIndex = 0,
            .writeIndex = 0,
    };

    gameStartAudioQueue = .{
        .ringBuffer = fixedAudioBuffer2,
        .readingActive = false,
        .soundsAdded = 0,
        .soundsPlayed = 0,
        .timeTillRead = gameStartTrackAudioQueueTime,
        .timeBetweenReads = gameStartTrackAudioQueueTimeDefault,
    };

    victoryAudioQueue = .{
        .ringBuffer = fixedAudioBuffer,
        .readingActive = false,
        .soundsAdded = 0,
        .soundsPlayed = 0,
        .timeTillRead = trackAudioQueueTime,
        .timeBetweenReads = audio_util_module.musicTrackAudioQueueTimeDefault,
    };
}

pub fn startTimers() void {
    timer_module.setTimeValuesMinutes(
        &trackTimeCountdown,
        0,
        snakeTimeRulesDefault.timeSeconds,
        snakeTimeRulesDefault.timeMinutes
    );

    timer_module.setTimeValuesMinutes(
        &trackAudioQueueTime,
        audio_util_module.musicTrackAudioQueueTimeDefault.frameCount,
        audio_util_module.musicTrackAudioQueueTimeDefault.seconds, 
        audio_util_module.musicTrackAudioQueueTimeDefault.minutes
    );

    timer_module.setTimeValuesSeconds(
        &gameStartTrackAudioQueueTime,
        gameStartTrackAudioQueueTimeDefault.frameCount,
        gameStartTrackAudioQueueTimeDefault.seconds
    );
}

export fn start() void {
    wasm4_module.PALETTE.* = palettes_module.spacehaze;

    var split: std.Random.SplitMix64 = std.Random.SplitMix64.init(@intFromPtr(wasm4_module.TIMESTAMP));
    prng = std.Random.DefaultPrng.init(split.next());
    randomNumberGenerator = prng.random();

    // Randomly generate X numbers to skip similar outputs before X
    const randomNumbers: u8 = 80;
    var randomCount: u8 = 0;
    while (randomCount < randomNumbers) : (randomCount += 1) {
        _ = randomNumberGenerator.int(u8);
    }

    prevInputState = wasm4_module.GAMEPAD1.*;

    rectAroundFood = geometry_module.Rectangle(i32).initCenter(snakeFood[0].position.x, snakeFood[0].position.y, 15, 15);

    spawnSnake();

    mapObstacles = obstacles_module.ObstaclesMap.init();

    startAudioQueues();
    startTimers();

    snake_audioModule.playGameStartSound(&gameStartAudioQueue);
}

export fn update() void {

    totalFrameCount = totalFrameCount + 1;
    frameCount = frameCount + 1;
    obstaclesFrameCount = obstaclesFrameCount + 1;

    // Input
    const activeButtonsThisFrame = wasm4_module.GAMEPAD1.* & (wasm4_module.GAMEPAD1.* ^ prevInputState);

    if (activeButtonsThisFrame & wasm4_module.BUTTON_UP != 0) {
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
            if (!snake_module.doesPossibleHeadDirHitNeck(playerSnake, snake_module.Direction.UP)) {
                snake_module.snakeInputDirection(&playerSnake, snake_module.Direction.UP);
            }
        }
    }

    if (activeButtonsThisFrame & wasm4_module.BUTTON_DOWN != 0) {
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
            if (!snake_module.doesPossibleHeadDirHitNeck(playerSnake, snake_module.Direction.DOWN)) {
                snake_module.snakeInputDirection(&playerSnake, snake_module.Direction.DOWN);
            }
        }
    }

    if (activeButtonsThisFrame & wasm4_module.BUTTON_LEFT != 0) {
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
            if (!snake_module.doesPossibleHeadDirHitNeck(playerSnake, snake_module.Direction.LEFT)) {
                snake_module.snakeInputDirection(&playerSnake, snake_module.Direction.LEFT);
            }
        }
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Paused) {
            if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Normal) {
                difficultyUISelection.currentDiff = snake_rules_module.DifficultyEnum.Easy;
            }
            else if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Hard) {
                difficultyUISelection.currentDiff = snake_rules_module.DifficultyEnum.Normal;
            }
        }
    }

    if (activeButtonsThisFrame & wasm4_module.BUTTON_RIGHT != 0) {
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
            if (!snake_module.doesPossibleHeadDirHitNeck(playerSnake, snake_module.Direction.RIGHT)) {
                snake_module.snakeInputDirection(&playerSnake, snake_module.Direction.RIGHT);
            }
        }
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Paused) {
            if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Easy) {
                difficultyUISelection.currentDiff = snake_rules_module.DifficultyEnum.Normal;
            }
            else if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Normal) {
                difficultyUISelection.currentDiff = snake_rules_module.DifficultyEnum.Hard;
            }
        }
    }

    if (activeButtonsThisFrame & wasm4_module.BUTTON_1 != 0) {
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Paused) {
            if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Easy) {
                snake_rules_module.changeSnakeDifficulty(&snakeGameState, snake_rules_module.DifficultyEnum.Easy);
            }
            else if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Normal) {
                snake_rules_module.changeSnakeDifficulty(&snakeGameState, snake_rules_module.DifficultyEnum.Normal);
            }
            else if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Hard) {
                snake_rules_module.changeSnakeDifficulty(&snakeGameState, snake_rules_module.DifficultyEnum.Hard);
            }

            resetGame();
        }
        else if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
            snakeGameState.matchPhase.currentPhase = gamestate_module.MatchPhaseEnum.Paused;
        }
        else if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Victory or
            snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Defeat) 
        {
            snakeGameState.matchPhase.currentPhase = gamestate_module.MatchPhaseEnum.Paused;
        }

    }
    prevInputState = wasm4_module.GAMEPAD1.*;

    // Trigger audio queues every loop
    if (audio_util_module.tryPlaySoundAudioRingBuffer(&gameStartAudioQueue)) {

    }
    if (audio_util_module.tryPlaySoundAudioRingBuffer(&victoryAudioQueue)) {
        
    }

    // Logic
    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Starting) {
        timer_module.trackTimeDecreasing(&gameStartTime);

        if (gameStartTime.frameCount == 0 and gameStartTime.seconds == 0) {
            snakeGameState.matchPhase.currentPhase = gamestate_module.MatchPhaseEnum.Active;

            gameStartTime = gameStartTimeDefault;
        }
    }

    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
        timer_module.trackTimeIncreasing(&trackTimePassed);
        
        timer_module.trackTimeDecreasing(&trackTimeCountdown);

        timer_module.trackTimeDecreasing(&trackObstacleSpawnTime);
    }

    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
        if (trackObstacleSpawnTime.frameCount == 0 and 
            trackObstacleSpawnTime.seconds == 0) 
        {
            // Spawn one obstacle
            obstacles_module.obstaclesSpawnSystem(&mapObstacles, 1, randomNumberGenerator, rectAroundFood, rectAroundFood2);
            
            obstacles_audio_module.playObstacleSpawnSound();

            // Get random offset for next spawn time frames
            const randomSpawnTimeOffset = randomNumberGenerator.intRangeAtMost(i8, -20, 20);
            // Reset timer
            const time = math_util_module.clamp(0, obstacleSpawnTimeDefault.frameCount + randomSpawnTimeOffset);
            trackObstacleSpawnTime.frameCount = @intCast(time);
            // Get random offset for next spawn time seconds
            const randomSpawnTimeOffsetSeconds = randomNumberGenerator.intRangeAtMost(i8, -2, 2);
            // Reset timer
            const timeSeconds = math_util_module.clamp(0, obstacleSpawnTimeDefault.timeSeconds + randomSpawnTimeOffsetSeconds);
            trackObstacleSpawnTime.seconds = @intCast(timeSeconds);
        }
        
    }

    if (obstaclesFrameCount % obstacles_module.obstacleLogicFrameTime == 0) {
        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
            obstacles_module.obstaclesDespawnSystem(&mapObstacles, mapBoundsBottom);
            // Move obstacles
            obstacles_module.obstaclesMoveSystem(&mapObstacles);
        }
        obstaclesFrameCount = 0;
    }

    if (frameCount % snake_module.snakeLogicFrameTime == 0) {

        if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {

            // Run snake and food logic
            snake_module.foodSpawnSystem(&snakeFood, 1, 1, 38, 1, 38, randomNumberGenerator);

            rectAroundFood = geometry_module.Rectangle(i32).initCenter(snakeFood[0].position.x, snakeFood[0].position.y, 15, 15);

            snake_module.snakeMoveSystem(&playerSnake);

            const foodIndexMatchFound: snake_module.FoodIndexMatch = snake_module.snakeFeedingSystem(&playerSnake, &snakeFood);
            const foodIndexArray: [1]u32 = .{foodIndexMatchFound.index};

            if (foodIndexMatchFound.match) {
                snake_audioModule.playFoodEatenSound();

                rectAroundFood2 = rectAroundFood;

                snake_module.foodDespawnSystem(&snakeFood, &foodIndexArray);

                // Reset countdown
                trackTimeCountdown = .{
                    .frameCount = 0,
                    .seconds = snakeGameState.snakeTimeRules.timeSeconds,
                    .minutes = snakeGameState.snakeTimeRules.timeMinutes,
                    .hours = snakeGameState.snakeTimeRules.timeHours,
                };
                trackTimePassed = .{
                    .frameCount = 0,
                    .seconds = 0,
                    .minutes = 0,
                    .hours = 0,
                };
            }

            // Check if snake collided with self or wall, or ran out of time
            const currentTime: snake_rules_module.SnakeTimeRulesState = .{
                .timeSeconds = trackTimePassed.seconds,
                .timeMinutes = trackTimePassed.minutes,
                .timeHours = trackTimePassed.hours,
            };

            if (snake_rules_module.tryHasSnakeLost(playerSnake, &snakeGameState, &mapBounds, .{ .i = 40 }, currentTime, mapObstacles)) {
                snake_audioModule.playDefeatSound();
            }
            if (snake_rules_module.tryHasSnakeWon(playerSnake, &snakeGameState)) {
                snake_audioModule.playVictorySound(&victoryAudioQueue);
            }
        }

        frameCount = 0;
    }

    // Render
    graphics_util_module.fill_c4();
    snake_graphics_module.drawMapBoundsAsWalls(&mapBounds, .{ .i = 40 }, 4);
    wasm4_module.DRAW_COLORS.* = 0x0001;

    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Starting) {
            if (gameStartTime.seconds == 2) {
                wasm4_module.text("3..", game_ui_module.getTitleTextPositionX(), game_ui_module.getTitleTextPositionY());
            }
            else if (gameStartTime.seconds == 1) {
                wasm4_module.text("2..", game_ui_module.getTitleTextPositionX(), game_ui_module.getTitleTextPositionY());
            }
            else if (gameStartTime.seconds == 0) {
                wasm4_module.text("1..", game_ui_module.getTitleTextPositionX(), game_ui_module.getTitleTextPositionY());
            }

            wasm4_module.text("Rock Slide Snake", 16, 60);

            wasm4_module.text("Move:", 60, 138);

            game_ui_module.drawArrowControls();
    }

    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Active) {
        const max_len = 20;

        var buf: [max_len]u8 = undefined;
        const currentSnakeSizeAsString = std.fmt.bufPrint(&buf, "{}", .{playerSnake.snakeSize.i}) catch unreachable;

        wasm4_module.text(currentSnakeSizeAsString, 30, 10);

        buf = undefined;
        const sizeGoalAsString = std.fmt.bufPrint(&buf, "{}", .{snakeGameState.sizeGoal.i}) catch unreachable;

        wasm4_module.text(sizeGoalAsString, 60, 10);

        graphics_util_module.renderTimeAsText(trackTimeCountdown.minutes, trackTimeCountdown.seconds, 90, 10);    

        obstacle_graphics_module.drawObstaclesMap(mapObstacles, 4);
        snake_graphics_module.drawSnakeAsRects(playerSnake, 4);
        snake_graphics_module.drawFoodAsRect(&snakeFood, 4);

    }

    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Paused) {
        // Draw options menu
        
        wasm4_module.text("Paused", game_ui_module.getTitleTextPositionX(), game_ui_module.getTitleTextPositionY());

        wasm4_module.text("Select Difficulty:", 10, 90);

        game_ui_module.drawDialogLine();

        wasm4_module.text("Easy", 14, 110);
        wasm4_module.text("Normal", 58, 110);
        wasm4_module.text("Hard", 118, 110);

        if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Easy) {
            wasm4_module.line(12, 120, 46, 120);
        }
        else if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Normal) {
            wasm4_module.line(56, 120, 106, 120);
        }
        else if (difficultyUISelection.currentDiff == snake_rules_module.DifficultyEnum.Hard) {
            wasm4_module.line(116, 120, 150, 120);
        }
        
        wasm4_module.text("Press X", 15, 140);

        game_ui_module.drawArrowControls();
    }

    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Victory) {
        wasm4_module.text("Victory!", game_ui_module.getTitleTextPositionX(), game_ui_module.getTitleTextPositionY());

        if (snakeGameState.sizeGoal.i == snake_rules_module.snakeRulesEasy.sizeGoal.i) {
            wasm4_module.text("Easy", 30, 30);
        }
        else if (snakeGameState.sizeGoal.i == snake_rules_module.snakeRulesNormal.sizeGoal.i) {
            wasm4_module.text("Normal", 30, 30);
        }
        else if (snakeGameState.sizeGoal.i == snake_rules_module.snakeRulesHard.sizeGoal.i) {
            wasm4_module.text("Hard", 30, 30);
        }

        wasm4_module.text("Try another", 10, 76);
        wasm4_module.text(" difficulty?", 18, 90);

        game_ui_module.drawDialogLine();

        wasm4_module.text("Press X", 54, 140);
    }

    if (snakeGameState.matchPhase.currentPhase == gamestate_module.MatchPhaseEnum.Defeat) {
        wasm4_module.text("Defeat", game_ui_module.getTitleTextPositionX(), game_ui_module.getTitleTextPositionY());

        const max_len = 20;

        var buf: [max_len]u8 = undefined;
        const currentSnakeSizeAsString = std.fmt.bufPrint(&buf, "{}", .{playerSnake.snakeSize.i}) catch unreachable;

        wasm4_module.text(currentSnakeSizeAsString, 30, 30);

        buf = undefined;
        const sizeGoalAsString = std.fmt.bufPrint(&buf, "{}", .{snakeGameState.sizeGoal.i}) catch unreachable;

        wasm4_module.text(sizeGoalAsString, 60, 30);

        graphics_util_module.renderTimeAsText(trackTimeCountdown.minutes, trackTimeCountdown.seconds, 90, 30);

        wasm4_module.text("Restart?", 10, 90);

        game_ui_module.drawDialogLine();

        wasm4_module.text("Press X", 54, 140);
    }
}