const std = @import("std");

const chunk = @import("chunk.zig");
const Chunk = chunk.Chunk;
const Opcode = chunk.Opcode;
const utils = @import("utils.zig");
const TC = utils.TermCodes;

const tc_chunk_header = .{TC.Style.bold};
const tc_op_name = .{TC.Style.magenta};
const tc_error = .{ TC.Style.bold, TC.Style.red };
const tc_addr = .{ TC.Style.italic, TC.Style.white };

pub fn disassembleChunk(ch: *const Chunk, name: []const u8, comptime colored: bool, writer: *std.io.Writer) !void {
    try writer.print("== {f} ==\n", .{TC.paint(tc_chunk_header, name, "{s}").setEnabled(colored)});
    var offset: usize = 0;
    while (offset < ch.count()) {
        offset = try disassembleInstruction(ch, offset, colored, writer);
    }
}

pub fn disassembleInstruction(
    ch: *const Chunk,
    offset: usize,
    comptime colored: bool,
    writer: *std.io.Writer,
) !usize {
    try writer.print("{f} ", .{TC.paint(tc_addr, offset, "0x{X:0>8}").setEnabled(colored)});

    const instruction = ch.code.items[offset];
    const op = std.enums.fromInt(Opcode, instruction) orelse {
        try writer.print("{f} {d}\n", .{
            TC.paint(tc_error, "Unknown opcode:", "{s}").setEnabled(colored),
            instruction,
        });
        return offset + 1;
    };

    switch (op) {
        .OP_RETURN => return try simpleInstruction("OP_RETURN", offset, colored, writer),
    }
}

fn simpleInstruction(
    name: []const u8,
    offset: usize,
    comptime colored: bool,
    writer: *std.io.Writer,
) !usize {
    try writer.print("{f}\n", .{TC.paint(tc_op_name, name, "{s}").setEnabled(colored)});
    return offset + 1;
}
