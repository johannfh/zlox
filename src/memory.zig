const std = @import("std");
const math = std.math;

pub inline fn grow_fit(current: usize, min_cap: usize) usize {
    if (min_cap <= current) return current;
    if (current == 0) {
        if (min_cap <= 8) return 8;
    }

    // don't expect overflows
    return math.ceilPowerOfTwo(usize, min_cap) catch unreachable;
}
