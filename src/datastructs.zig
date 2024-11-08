
// What is a ring buffer? https://en.wikipedia.org/wiki/Circular_buffer
// Uses 64 size fixed array for buffer
pub fn FixedArrayRingBuffer(comptime T: type) type {
    return struct {
        arrayT: [64]T,
        usedLen: usize,
        readIndex: usize,
        writeIndex: usize,

        
        pub fn tryAdd(self: *@This(), thing: T) bool {
            if (self.usedLen == self.arrayT.len) {
                return false;
            }
            if (self.writeIndex == (self.arrayT.len - 1)) {
                self.arrayT[self.writeIndex] = thing;
                self.usedLen += 1;
                self.writeIndex = 0;
                return true;
            }
            else {
                self.arrayT[self.writeIndex] = thing;
                self.usedLen += 1;
                self.writeIndex = self.writeIndex + 1;
            }

            return true;
        }

        pub fn read(self: *@This()) T {
            const currentRead = self.arrayT[self.readIndex];
            if (self.readIndex == (self.arrayT.len - 1)) {
                self.readIndex = 0;
            }
            else {
                self.readIndex = self.readIndex + 1;
                self.usedLen -= 1;
            }

            return currentRead;
        }
    };
}