const std = @import("std");
const assert = std.debug.assert;
const expectEqual = std.testing.expectEqual;
const expectEqualDeep = std.testing.expectEqualDeep;

pub fn Rectangle(comptime T: type) type {
    switch (@typeInfo(T)) {
        .int, .float => {},
        else => @compileError("Unsupported type " ++ @typeName(T) ++ " for Rectangle"),
    }
    return struct {
        const Self = @This();
        l: T,
        t: T,
        r: T,
        b: T,

        /// Initialize a rectangle by giving its four sides.
        pub fn init(l: T, t: T, r: T, b: T) Self {
            assert(r > l and b > t);
            return .{ .l = l, .t = t, .r = r, .b = b };
        }

        /// Initialize a rectangle at center x, y with the specified width and height.
        pub fn initCenter(x: T, y: T, w: T, h: T) Self {
            assert(w > 0 and h > 0);
            switch (@typeInfo(T)) {
                .int => {
                    const l = x - @divFloor(w, 2);
                    const t = y - @divFloor(h, 2);
                    const r = l + w - 1;
                    const b = t + h - 1;
                    return Self.init(l, t, r, b);
                },
                .float => {
                    const l = x - w / 2;
                    const t = y - h / 2;
                    const r = l + w;
                    const b = t + h;
                    return Self.init(l, t, r, b);
                },
                else => @compileError("Unsupported type " ++ @typeName(T) ++ " for Rectangle"),
            }
        }

        /// Casts self's underlying type to U.
        pub fn cast(self: Self, comptime U: type) Rectangle(U) {
            return .{
                .l = @as(U, self.l),
                .t = @as(U, self.t),
                .r = @as(U, self.r),
                .b = @as(U, self.b),
            };
        }

        /// Checks if a rectangle is ill-formed.
        pub fn isEmpty(self: Self) bool {
            return switch (@typeInfo(T)) {
                .int => self.t > self.b or self.l > self.r,
                .float => self.t >= self.b or self.l >= self.r,
                else => @compileError("Unsupported type " ++ @typeName(T) ++ " for Rectangle"),
            };
        }

        /// Returns the width of the rectangle.
        pub fn width(self: Self) if (@typeInfo(T) == .int) usize else T {
            return if (self.isEmpty()) 0 else switch (@typeInfo(T)) {
                .int => @intCast(self.r - self.l + 1),
                .float => self.r - self.l,
                else => @compileError("Unsupported type " ++ @typeName(T) ++ " for Rectangle"),
            };
        }

        /// Returns the height of the rectangle.
        pub fn height(self: Self) if (@typeInfo(T) == .int) usize else T {
            return if (self.isEmpty()) 0 else switch (@typeInfo(T)) {
                .int => @intCast(self.b - self.t + 1),
                .float => self.b - self.t,
                else => @compileError("Unsupported type " ++ @typeName(T) ++ " for Rectangle"),
            };
        }

        /// Returns the area of the rectangle
        pub fn area(self: Self) if (@typeInfo(T) == .int) usize else T {
            return self.height() * self.width();
        }

        /// Returns true if the point at x, y is inside the rectangle.
        pub fn contains(self: Self, x: T, y: T) bool {
            if (x < self.l or x > self.r or y < self.t or y > self.b) {
                return false;
            }
            return true;
        }
    };
}