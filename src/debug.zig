const std = @import("std");

const chunk = @import("chunk.zig");
const Chunk = chunk.Chunk;
const Opcode = chunk.Opcode;

pub fn disassembleChunk(ch: *const Chunk, name: []const u8, writer: anytype) !void {
    try writer.print("== {s} ==\n", .{name});
    try writer.print("offset line instruction\n", .{});
    var offset: usize = 0;
    while (offset < ch.count()) {
        offset = try disassembleInstruction(ch, offset, writer);
    }
}

pub fn disassembleInstruction(
    ch: *const Chunk,
    offset: usize,
    writer: anytype,
) !usize {
    try writer.print("0x{X:0>4} ", .{offset});
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
        .OP_RETURN => return try simpleInstruction(op, offset, writer),
        .OP_CONSTANT => return try constantInstruction(op, ch, offset, writer),
        .OP_ADD => return try simpleInstruction(op, offset, writer),
        .OP_SUBTRACT => return try simpleInstruction(op, offset, writer),
        .OP_MULTIPLY => return try simpleInstruction(op, offset, writer),
        .OP_DIVIDE => return try simpleInstruction(op, offset, writer),
    }
}

fn simpleInstruction(
    opcode: Opcode,
    offset: usize,
    writer: anytype,
) !usize {
    try writer.print("{f}\n", .{opcode});
    return offset + 1;
}

fn constantInstruction(
    opcode: Opcode,
    ch: *const Chunk,
    offset: usize,
    writer: anytype,
) !usize {
    const constant = ch.code.items[offset + 1];
    try writer.print("{f} {d:0>4} {f}\n", .{ opcode, constant, ch.constants.items[constant] });
    return offset + 2;
}
