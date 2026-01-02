const std = @import("std");
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");

const zlox = @import("zlox");
const Chunk = zlox.chunk.Chunk;
const debug = zlox.debug;
const VM = zlox.vm.VM;
const Value = zlox.value.Value;

// 1 MiB
const stack_size = 2 << 20;

fn repl(gpa: Allocator) !void {
    var stdin_buf: [1024]u8 = undefined;
    var stdin_raw = std.fs.File.stdin().reader(&stdin_buf);
    const stdin = &stdin_raw.interface;

    var stdout_buf: [1024]u8 = undefined;
    var stdout_raw = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_raw.interface;

    while (true) {
        try stdout.print("> ", .{});
        try stdout.flush();
        const input = try stdin.takeDelimiter('\n');
        if (input) |in| {
            try stdout.print("Got input: '{s}'\n", .{in});
        }
    }
    _ = gpa;
    try stdout.flush();
}

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

    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len == 1) {
        try repl(gpa);
    } else {
        std.debug.print("Usage: zlox [path]\n", .{});
    }
}
