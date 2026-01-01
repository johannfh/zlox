const std = @import("std");
const expectEqual = std.testing.expectEqual;

pub fn hexDigitsRequired(comptime T: type, value: T) T {
    if (value == 0) return 1;
    // log2(value) + 1
    const bits = std.math.log2(value) + 1;
    // ceiling division
    return (bits + 3) / 4;
}

test "hexDigitsRequired logic" {
    const Case = struct { val: usize, expected: usize };
    const cases = [_]Case{
        .{ .val = 0, .expected = 1 },
        .{ .val = 50000, .expected = 4 },
        .{ .val = 0xFFFF, .expected = 4 },
        .{ .val = 100000, .expected = 5 },
        .{ .val = 0xFFFFFFFF, .expected = 8 },
    };
    for (cases) |c| {
        try expectEqual(c.expected, hexDigitsRequired(usize, c.val));
    }
}
