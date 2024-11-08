// Collection of utility functions for playing audio on the WASM-4 fantasy console.

const std = @import("std");

const wasm4_module = @import("wasm4.zig");
const timer_module = @import("timer.zig");
const datastructs_module = @import("datastructs.zig");

// Audio note queue that can play sounds from a queue in order to make music
// Use Sound with no freq to create empty space
// Call every frame, automatic play of next note at readIndex when frames reach required number
// Max queue is 64
pub const AudioRingBuffer = struct {
    ringBuffer: datastructs_module.FixedArrayRingBuffer(Sound),
    soundsAdded: u32,
    soundsPlayed: u32,
    // Tracks time till next read
    timeTillRead: timer_module.TimeTracker,
    // Use to set time between reads
    timeBetweenReads: timer_module.TimeTracker,
    // Enable to begin reading
    readingActive: bool,
};

pub fn tryAddToAudioRingBuffer(sound: Sound, audioRingBuffer: *AudioRingBuffer) bool {
    // Try to add sound to ring buffer
    if (audioRingBuffer.ringBuffer.tryAdd(sound)) {
        audioRingBuffer.soundsAdded += 1;
        // Set reading active to kick off sound playing
        audioRingBuffer.readingActive = true;
        return true;
    }

    return false;
}

pub fn tryPlaySoundAudioRingBuffer(audioRingBuffer: *AudioRingBuffer) bool {
    if (audioRingBuffer.readingActive) {
        if (audioRingBuffer.soundsAdded > audioRingBuffer.soundsPlayed) {

            if (audioRingBuffer.timeTillRead.frameCount == 0 and 
                audioRingBuffer.timeTillRead.seconds == 0) {
                // Reset timeTillRead
                audioRingBuffer.timeTillRead = .{
                    .frameCount = audioRingBuffer.timeBetweenReads.frameCount,
                    .seconds = audioRingBuffer.timeBetweenReads.seconds,
                    .minutes = audioRingBuffer.timeBetweenReads.minutes,
                    .hours = audioRingBuffer.timeBetweenReads.hours
                };

                playWASM4Tone(audioRingBuffer.ringBuffer.read());

                audioRingBuffer.soundsPlayed += 1;
                
                if (audioRingBuffer.soundsPlayed == audioRingBuffer.soundsAdded) {
                    // Set reading inactive to stop playing sounds
                    audioRingBuffer.readingActive = false;
                }

                // Tick down on queue timer
                timer_module.trackTimeDecreasing(&audioRingBuffer.timeTillRead);

                return true;
            }


            
        }

        // Tick down on queue timer
        timer_module.trackTimeDecreasing(&audioRingBuffer.timeTillRead);
    }
    return false;
}


pub const Sound = struct {
	freq1:    u32,
	freq2:    u32,
	attack:   u32,
	decay:    u32,
	sustain:  u32,
	release:  u32,
	volume:   u32,
	channel:  u32,
	mode:     u32,
};

// Set freq1 to multiplier of 10
// e.g. Middle C = 60 * 10
pub const PianoNoteSound: Sound = .{
    .freq1 =    0,
	.freq2 =    0,
	.attack =   0,
	.decay =    8,
	.sustain =  10,
	.release =  4,
	.volume =   60,
	.channel =  0,
	.mode =     0 | wasm4_module.TONE_NOTE_MODE,
};

pub const musicTrackAudioQueueTimeDefault : timer_module.TimeTracker = .{
    .frameCount = 12,
    .seconds = 0,
    .minutes = 0,
    .hours = 0,
};

pub fn playWASM4Tone(sound: Sound) void {
    wasm4_module.tone(
        sound.freq1 | (sound.freq2 << 16), 
        (sound.attack << 24) | (sound.decay << 16) | sound.sustain | (sound.release << 8),
        sound.volume, 
        sound.channel | (sound.mode << 2)
    );
}

pub fn playWASM4PianoNote(note: u32) void {
    var noteAsSound: Sound = PianoNoteSound;
    noteAsSound.freq1 = note * 10;
    playWASM4Tone(noteAsSound);
}