const vm = @import("vm.zig");
const InterpretError = vm.InterpretError;

pub const Value = union(enum) {
    const This = @This();
    number: f64,

    pub fn add(lhs: This, rhs: This) InterpretError!This {
        if (lhs == .number and rhs == .number) {
            return .{ .number = lhs.number + rhs.number };
        }
        return error.RuntimeTypeError;
    }

    pub fn subtract(lhs: This, rhs: This) InterpretError!This {
        if (lhs == .number and rhs == .number) {
            return .{ .number = lhs.number - rhs.number };
        }
        return error.RuntimeTypeError;
    }

    pub fn multiply(lhs: This, rhs: This) InterpretError!This {
        if (lhs == .number and rhs == .number) {
            return .{ .number = lhs.number * rhs.number };
        }
        return error.RuntimeTypeError;
    }

    pub fn divide(lhs: This, rhs: This) InterpretError!This {
        if (lhs == .number and rhs == .number) {
            return .{ .number = lhs.number / rhs.number };
        }
        return error.RuntimeTypeError;
    }
    pub fn format(this: *const @This(), writer: anytype) !void {
        switch (this.*) {
            .number => |v| try writer.print("{d}", .{v}),
        }
    }
};
