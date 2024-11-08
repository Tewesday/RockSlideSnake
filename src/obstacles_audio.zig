const audio_util_module = @import("audio_util.zig");

const ObstacleSpawnSound: audio_util_module.Sound = .{
    .freq1 =    280,
	.freq2 =    130,
	.attack =   24,
	.decay =    6,
	.sustain =  4,
	.release =  2,
	.volume =   50,
	.channel =  3,
	.mode =     0,
};

pub fn playObstacleSpawnSound() void {
    audio_util_module.playWASM4Tone(ObstacleSpawnSound);
}