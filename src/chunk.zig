const std = @import("std");
const Allocator = std.mem.Allocator;

const memory = @import("memory.zig");
const ArrayList = std.ArrayList;

const Value = @import("value.zig").Value;

pub const Opcode = enum(u8) {
    OP_RETURN,
    OP_CONSTANT,

    pub fn toString(this: @This()) []const u8 {
        switch (this) {
            .OP_RETURN => return "OP_RETURN",
            .OP_CONSTANT => return "OP_CONSTANT",
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

    pub fn writeConstant(this: *This, gpa: Allocator, value: Value) !u8 {
        if (this.constants.items.len >= 256) return error.MaxConstantsReached;
        try this.constants.append(gpa, value);
        return @intCast(this.constants.items.len - 1);
    }

    pub fn readConstant(this: *This, idx: usize) Value {
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
