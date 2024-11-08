const std = @import("std");

pub const Point = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) Point {
        return .{
            .x = x,
            .y = y,
        };
    }
};

pub fn equalPoints(a: Point, b: Point) bool {
    return (a.x == b.x) and (a.y == b.y);
}

pub const PointMatch4 = struct {
    match: bool,
    pointIndex: IndexOfPointsArray4,
    pointValue: Point,
};

pub const PointsArray4 = struct {
    x: [4]i32,
    y: [4]i32,
};

pub const IndexOfPointsArray4 = struct {
    i: u8,
};

pub const PointMatch = struct {
    match: bool,
    pointIndex: IndexOfPointsArray64,
    pointValue: Point,
};

pub const PointsArray64 = struct {
    x: [64]i32,
    y: [64]i32,
};

pub const IndexOfPointsArray64 = struct {
    i: u8,
};

pub fn equalPointsRaw(aX: i32, aY: i32, bX: i32, bY: i32) bool {
    return (aX == bX) and (aY == bY);
}

pub fn equalPointsArray(a: PointsArray64, b: PointsArray64) bool {
    var xComparisonEqual: bool = false;
    var yComparisonEqual: bool = false;

    for (a.x, b.x) |aX, bX| {
        if (aX == bX) {
            xComparisonEqual = true;
        } else {
            return false;
        }
    }

    for (a.y, b.y) |aY, bY| {
        if (aY == bY) {
            yComparisonEqual = true;
        } else {
            return false;
        }
    }

    return xComparisonEqual and yComparisonEqual;
}

pub fn equalPointsArrayRawSliced(aX: []const i32, aY: []const i32, bX: []const i32, bY: []const i32) bool {
    var xComparisonEqual: bool = false;
    var yComparisonEqual: bool = false;

    for (aX, bX) |aXelement, bXelement| {
        if (aXelement == bXelement) {
            xComparisonEqual = true;
        } else {
            return false;
        }
    }

    for (aY, bY) |aYelement, bYelement| {
        if (aYelement == bYelement) {
            yComparisonEqual = true;
        } else {
            return false;
        }
    }

    return xComparisonEqual and yComparisonEqual;
}

// Find point in pointsArray from first to last
pub fn findPointInPointsArray64(pointX: i32, pointY: i32, points: PointsArray64, firstPoint: IndexOfPointsArray64, lastPoint: IndexOfPointsArray64) PointMatch {
    var posIndex: IndexOfPointsArray64 = firstPoint;
    while (posIndex.i <= lastPoint.i) : (posIndex.i += 1) {
        if ((points.x[posIndex.i] == pointX) and (points.y[posIndex.i] == pointY)) {
            return .{ .match = true, .pointIndex = posIndex, .pointValue = .{ .x = points.x[posIndex.i], .y = points.y[posIndex.i] } };
        }
    }

    return .{ .match = false, .pointIndex = .{ .i = 0 }, .pointValue = .{ .x = 0, .y = 0 } };
}

// Find point in pointsArray from first to last
pub fn findPointInPointsArray4(pointX: i32, pointY: i32, points: PointsArray4, firstPoint: IndexOfPointsArray4, lastPoint: IndexOfPointsArray4) PointMatch4 {
    var posIndex: IndexOfPointsArray4 = firstPoint;
    while (posIndex.i <= lastPoint.i) : (posIndex.i += 1) {
        if ((points.x[posIndex.i] == pointX) and (points.y[posIndex.i] == pointY)) {
            return .{ .match = true, .pointIndex = posIndex, .pointValue = .{ .x = points.x[posIndex.i], .y = points.y[posIndex.i] } };
        }
    }

    return .{ .match = false, .pointIndex = .{ .i = 0 }, .pointValue = .{ .x = 0, .y = 0 } };
}

// Get random point within given bounds
pub fn getRandomPointInRange(boundXBegin: i32, boundXEnd: i32, boundYBegin: i32, boundYEnd: i32, randomNumberGenerator: std.Random) Point {
    const randomX = randomNumberGenerator.intRangeLessThan(i32, boundXBegin, boundXEnd);
    const randomY = randomNumberGenerator.intRangeLessThan(i32, boundYBegin, boundYEnd);
    return .{ .x = randomX, .y = randomY };
}


pub fn getEucDistanceBetweenPoints(firstPoint: Point, secondPoint: Point) u32 {
    return ((firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x)
     + (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y));
}

pub fn getMaxMinDistanceBetweenPoints(firstPoint: Point, secondPoint: Point) u32 {
    const distanceX = @abs(firstPoint.x - secondPoint.x);
    const distanceY = @abs(firstPoint.y - secondPoint.y);
    const distance = (1 / 2) * (distanceX + distanceY + @max(distanceX, distanceY));
    return distance;
}

pub fn getSqrtDistanceBetweenPoints(firstPoint: Point, secondPoint: Point) u32 {
    const distanceX = @abs(firstPoint.x - secondPoint.x);
    const distanceY = @abs(firstPoint.y - secondPoint.y);
    const float: f32 = @floatFromInt((distanceX + distanceY));
    const distance = @sqrt(float);
    return @intFromFloat(distance);
}