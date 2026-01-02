const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Value = @import("value.zig").Value;

pub const Opcode = enum(u8) {
    OP_RETURN,
    OP_CONSTANT,
    OP_ADD,
    OP_SUBTRACT,
    OP_MULTIPLY,
    OP_DIVIDE,

    pub fn toString(this: @This()) []const u8 {
        switch (this) {
            .OP_RETURN => return "OP_RETURN",
            .OP_CONSTANT => return "OP_CONSTANT",
            .OP_ADD => return "OP_ADD",
            .OP_SUBTRACT => return "OP_SUBTRACT",
            .OP_MULTIPLY => return "OP_MULTIPLY",
            .OP_DIVIDE => return "OP_DIVIDE",
        }
    }

    pub fn format(
        this: @This(),
        writer: anytype,
    ) !void {
        try writer.print("{s}", .{this.toString()});
    }
};

pub const Chunk = struct {
    const This = @This();

    code: ArrayList(u8),
    lines: ArrayList(usize),
    constants: ArrayList(Value),

    pub fn new() This {
        return .{
            .code = ArrayList(u8).empty,
            .lines = ArrayList(usize).empty,
            .constants = ArrayList(Value).empty,
        };
    }

    pub fn write(this: *This, gpa: Allocator, byte: u8, line: usize) Allocator.Error!void {
        try this.code.append(gpa, byte);
        try this.lines.append(gpa, line);
    }

    pub fn writeSlice(this: *This, gpa: Allocator, bytes: []const u8) Allocator.Error!void {
        try this.code.appendSlice(gpa, bytes);
    }

    pub fn writeOpcode(this: *This, gpa: Allocator, opcode: Opcode, line: usize) Allocator.Error!void {
        try this.write(gpa, @intFromEnum(opcode), line);
    }

    pub fn writeConstant(this: *This, gpa: Allocator, value: Value) !usize {
        if (this.constants.items.len >= 256) return error.MaxConstantsReached;
        try this.constants.append(gpa, value);
        const idx: usize = @intCast(this.constants.items.len - 1);
        std.debug.print("Wrote constant {f} to index {d}\n", .{ value, idx });
        return idx;
    }

    pub fn readConstant(this: *const This, idx: usize) Value {
        return this.constants.items[idx];
    }

    pub fn count(this: *const This) usize {
        return this.code.items.len;
    }

    pub fn deinit(this: *This, gpa: Allocator) void {
        this.code.deinit(gpa);
        this.lines.deinit(gpa);
        this.constants.deinit(gpa);
    }
};
