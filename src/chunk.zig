const std = @import("std");
const Allocator = std.mem.Allocator;

const memory = @import("memory.zig");
const ArrayList = std.ArrayList;

const Value = @import("value.zig").Value;

pub const Opcode = enum(u8) {
    OP_RETURN,
    OP_CONSTANT,
};

pub const Chunk = struct {
    const Self = @This();

    code: ArrayList(u8),
    lines: ArrayList(usize),
    constants: ArrayList(Value),

    pub fn new() Self {
        return .{
            .code = ArrayList(u8).empty,
            .lines = ArrayList(usize).empty,
            .constants = ArrayList(Value).empty,
        };
    }

    pub fn write(self: *Self, gpa: Allocator, byte: u8, line: usize) Allocator.Error!void {
        try self.code.append(gpa, byte);
        try self.lines.append(gpa, line);
    }

    pub fn writeSlice(self: *Self, gpa: Allocator, bytes: []const u8) Allocator.Error!void {
        try self.code.appendSlice(gpa, bytes);
    }

    pub fn writeOpcode(self: *Self, gpa: Allocator, opcode: Opcode, line: usize) Allocator.Error!void {
        try self.write(gpa, @intFromEnum(opcode), line);
    }

    pub fn writeConstant(self: *Self, gpa: Allocator, value: Value) !u8 {
        if (self.constants.items.len >= 256) return error.MaxConstantsReached;
        try self.constants.append(gpa, value);
        return @intCast(self.constants.items.len - 1);
    }

    pub fn count(self: *const Self) usize {
        return self.code.items.len;
    }

    pub fn deinit(self: *Self, gpa: Allocator) void {
        self.code.deinit(gpa);
        self.lines.deinit(gpa);
        self.constants.deinit(gpa);
    }
};
