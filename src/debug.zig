const std = @import("std");

const chunk = @import("chunk.zig");
const Chunk = chunk.Chunk;
const Opcode = chunk.Opcode;
const utils = @import("utils.zig");
const printValue = @import("value.zig").printValue;

pub fn disassembleChunk(ch: *const Chunk, name: []const u8, writer: anytype) !void {
    const hexDigitsRequired = utils.hexDigitsRequired(usize, ch.count() - 1);
    try writer.print("== {s} ==\n", .{name});
    var offset: usize = 0;
    while (offset < ch.count()) {
        offset = try disassembleInstruction(ch, offset, hexDigitsRequired, writer);
    }
}

pub fn disassembleInstruction(
    ch: *const Chunk,
    offset: usize,
    hexDigitsRequired: usize,
    writer: anytype,
) !usize {
    try writer.print("0x{X:0>[1]} ", .{ offset, hexDigitsRequired });
    if (offset > 0 and ch.lines.items[offset] == ch.lines.items[offset - 1]) {
        try writer.print("   | ", .{});
    } else {
        try writer.print("{d:>4} ", .{ch.lines.items[offset]});
    }

    const instruction = ch.code.items[offset];
    const op = std.enums.fromInt(Opcode, instruction) orelse {
        try writer.print("Unknown opcode: {d}\n", .{instruction});
        return offset + 1;
    };

    switch (op) {
        .OP_RETURN => return try simpleInstruction("OP_RETURN", offset, writer),
        .OP_CONSTANT => return try constantInstruction("OP_CONSTANT", ch, offset, writer),
    }
}

fn simpleInstruction(
    name: []const u8,
    offset: usize,
    writer: anytype,
) !usize {
    try writer.print("{s}\n", .{name});
    return offset + 1;
}

fn constantInstruction(
    name: []const u8,
    ch: *const Chunk,
    offset: usize,
    writer: anytype,
) !usize {
    const constant = ch.code.items[offset + 1];
    try writer.print("{s} {d:0>4} {any}\n", .{ name, constant, ch.constants.items[constant] });
    return offset + 2;
}
