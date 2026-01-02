const std = @import("std");
const builtin = @import("builtin");

const zlox = @import("zlox");
const Chunk = zlox.chunk.Chunk;
const debug = zlox.debug;
const VM = zlox.vm.VM;

pub fn main() !void {
    const is_debug = builtin.mode == .Debug;

    var debug_allocator = if (is_debug) std.heap.DebugAllocator(.{}).init else struct {}{};
    const gpa = if (is_debug) debug_allocator.allocator() else std.heap.page_allocator;
    defer if (is_debug) {
        const check = debug_allocator.deinit();
        if (check == .leak) {
            std.debug.print("Memory leak detected!\n", .{});
        }
    };

    if (is_debug) {
        std.debug.print("Running in debug mode\n", .{});
    } else {
        std.debug.print("Running in release mode\n", .{});
    }

    var chunk = Chunk.new();
    defer chunk.deinit(gpa);

    const const_idx = try chunk.writeConstant(gpa, 3.14159);

    try chunk.writeOpcode(gpa, .OP_CONSTANT, 1);
    try chunk.write(gpa, const_idx, 1);
    try chunk.writeOpcode(gpa, .OP_RETURN, 2);

    var buf: [1024]u8 = undefined;
    var stderr = std.fs.File.stderr().writer(&buf);
    try debug.disassembleChunk(&chunk, "main.lox", &stderr.interface);
    try stderr.interface.flush();

    var vm = VM.init(&chunk);
    vm.run() catch |err| {
        std.debug.print("Error occured while executing: {any}\n", .{err});
        return err;
    };
}
