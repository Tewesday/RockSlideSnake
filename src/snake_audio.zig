const audio_util = @import("audio_util.zig");

// Play 3 times
const GameStartYellowLight: audio_util.Sound = .{
    .freq1 =    130,
	.freq2 =    130,
	.attack =   24,
	.decay =    6,
	.sustain =  4,
	.release =  2,
	.volume =   80,
	.channel =  2,
	.mode =     0,
};

// Play 1 time
const GameStartGreenLight: audio_util.Sound = .{
    .freq1 =    130,
	.freq2 =    270,
	.attack =   24,
	.decay =    6,
	.sustain =  4,
	.release =  2,
	.volume =   80,
	.channel =  2,
	.mode =     0,
};

const FoodEatenSound: audio_util.Sound = .{
    .freq1 =    110,
	.freq2 =    330,
	.attack =   0,
	.decay =    0,
	.sustain =  14,
	.release =  0,
	.volume =   60,
	.channel =  0,
	.mode =     0,
};

const DefeatSound: audio_util.Sound = .{
    .freq1 =    200,
	.freq2 =    100,
	.attack =   40,
	.decay =    14,
	.sustain =  16,
	.release =  8,
	.volume =   60,
	.channel =  0,
	.mode =     0,
};

pub fn playFoodEatenSound() void {
    audio_util.playWASM4Tone(FoodEatenSound);
}

pub fn playGameStartSound(audioRingBuffer: *audio_util.AudioRingBuffer) void {
    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = GameStartYellowLight.freq1,
            .freq2 = GameStartYellowLight.freq2,
            .attack = GameStartYellowLight.attack,
            .decay = GameStartYellowLight.decay,
            .sustain = GameStartYellowLight.sustain,
            .release = GameStartYellowLight.release,
            .volume = GameStartYellowLight.volume,
            .channel = GameStartYellowLight.channel,
            .mode = GameStartYellowLight.mode,
        },
        audioRingBuffer
    );
    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = GameStartYellowLight.freq1,
            .freq2 = GameStartYellowLight.freq2,
            .attack = GameStartYellowLight.attack,
            .decay = GameStartYellowLight.decay,
            .sustain = GameStartYellowLight.sustain,
            .release = GameStartYellowLight.release,
            .volume = GameStartYellowLight.volume,
            .channel = GameStartYellowLight.channel,
            .mode = GameStartYellowLight.mode,
        },
        audioRingBuffer
    );
    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = GameStartYellowLight.freq1,
            .freq2 = GameStartYellowLight.freq2,
            .attack = GameStartYellowLight.attack,
            .decay = GameStartYellowLight.decay,
            .sustain = GameStartYellowLight.sustain,
            .release = GameStartYellowLight.release,
            .volume = GameStartYellowLight.volume,
            .channel = GameStartYellowLight.channel,
            .mode = GameStartYellowLight.mode,
        },
        audioRingBuffer
    );
    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = GameStartGreenLight.freq1,
            .freq2 = GameStartGreenLight.freq2,
            .attack = GameStartGreenLight.attack,
            .decay = GameStartGreenLight.decay,
            .sustain = GameStartGreenLight.sustain,
            .release = GameStartGreenLight.release,
            .volume = GameStartGreenLight.volume,
            .channel = GameStartGreenLight.channel,
            .mode = GameStartGreenLight.mode,
        },
        audioRingBuffer
    );
}

pub fn playVictorySound(audioRingBuffer: *audio_util.AudioRingBuffer) void {

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 56 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 0,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 56 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 57 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 58 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 60 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 60 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 0,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 58 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 0,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 58 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );

    _ = audio_util.tryAddToAudioRingBuffer(
    .{ 
            .freq1 = 60 * 10,
            .freq2 = audio_util.PianoNoteSound.freq2,
            .attack = audio_util.PianoNoteSound.attack,
            .decay = audio_util.PianoNoteSound.decay,
            .sustain = audio_util.PianoNoteSound.sustain,
            .release = audio_util.PianoNoteSound.release,
            .volume = audio_util.PianoNoteSound.volume,
            .channel = audio_util.PianoNoteSound.channel,
            .mode = audio_util.PianoNoteSound.mode,
        },
         audioRingBuffer
    );
}

pub fn playDefeatSound() void {
    audio_util.playWASM4Tone(DefeatSound);
}