const std = @import("std");
const Allocator = std.mem.Allocator;

const memory = @import("memory.zig");
const ArrayList = std.ArrayList;

pub const Opcode = enum(u8) {
    OP_RETURN,
};

pub const Chunk = struct {
    const Self = @This();

    code: ArrayList(u8),

    pub fn new() Self {
        return .{
            .code = ArrayList(u8).empty,
        };
    }

    pub fn write(self: *Self, allocator: Allocator, byte: u8) Allocator.Error!void {
        try self.code.append(allocator, byte);
    }

    pub fn writeSlice(self: *Self, allocator: Allocator, bytes: []const u8) Allocator.Error!void {
        try self.code.appendSlice(allocator, bytes);
    }

    pub fn writeOpcode(self: *Self, allocator: Allocator, opcode: Opcode) Allocator.Error!void {
        try self.write(allocator, @intFromEnum(opcode));
    }

    pub fn count(self: *const Self) usize {
        return self.code.items.len;
    }
};
