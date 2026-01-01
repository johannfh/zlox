const std = @import("std");
const Allocator = std.mem.Allocator;

const memory = @import("memory.zig");
const ArrayList = std.ArrayList;

pub const Opcode = enum(u8) {
    OP_RETURN,
};

pub const Value = f64;

pub const Chunk = struct {
    const Self = @This();

    code: ArrayList(u8),
    constants: ArrayList(Value),

    pub fn new() Self {
        return .{
            .code = ArrayList(u8).empty,
            .constants = ArrayList(Value).empty,
        };
    }

    pub fn write(self: *Self, gpa: Allocator, byte: u8) Allocator.Error!void {
        try self.code.append(gpa, byte);
    }

    pub fn writeSlice(self: *Self, gpa: Allocator, bytes: []const u8) Allocator.Error!void {
        try self.code.appendSlice(gpa, bytes);
    }

    pub fn writeOpcode(self: *Self, gpa: Allocator, opcode: Opcode) Allocator.Error!void {
        try self.write(gpa, @intFromEnum(opcode));
    }

    pub fn writeConstant(self: *Self, gpa: Allocator, value: Value) Allocator.Error!void {
        try self.constants.append(gpa, value);
    }

    pub fn count(self: *const Self) usize {
        return self.code.items.len;
    }

    pub fn deinit(self: *Self, gpa: Allocator) void {
        self.code.deinit(gpa);
        self.constants.deinit(gpa);
    }
};
