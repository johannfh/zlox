const std = @import("std");
const zlox = @import("zlox");
const Chunk = zlox.chunk.Chunk;
const debug = zlox.debug;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var chunk = Chunk.new();
    try chunk.writeOpcode(allocator, .OP_RETURN);
    try chunk.writeOpcode(allocator, .OP_RETURN);
    try chunk.write(allocator, 5);
    try chunk.writeOpcode(allocator, .OP_RETURN);

    var buf: [1024]u8 = undefined;
    var stderr = std.fs.File.stderr().writer(&buf);
    const stderr_writer = &stderr.interface;

    try debug.disassembleChunk(&chunk, "main.lox", true, stderr_writer);
    try stderr_writer.flush();
}
