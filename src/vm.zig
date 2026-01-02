const builtin = @import("builtin");
const std = @import("std");

const ch = @import("chunk.zig");
const Chunk = ch.Chunk;
const Opcode = ch.Opcode;

pub const InterpretError = error{
    CompileError,
    UnknownOpcode,
    IpOob,
};

pub const VM = struct {
    chunk: *const Chunk,
    ip: usize,

    pub fn init(c: *const Chunk) @This() {
        return .{ .chunk = c, .ip = 0 };
    }

    inline fn readByte(this: *@This()) InterpretError!u8 {
        // in debug mode, do bounds checks on every readByte call (expensive)
        if (builtin.mode == .Debug) {
            if (this.ip >= this.chunk.count()) {
                return error.IpOob;
            }
        }

        const byte = this.chunk.code.items[this.ip];
        this.ip += 1;
        return byte;
    }

    pub fn run(this: *@This()) InterpretError!void {
        while (true) {
            const instruction = try this.readByte();
            const opcode = std.enums.fromInt(Opcode, instruction) orelse {
                return error.UnknownOpcode;
            };
            std.debug.print("Executing {f} at offset 0x{X}\n", .{opcode, this.ip-1});

            switch (opcode) {
                .OP_RETURN => return,
                .OP_CONSTANT => {
                    const idx = try this.readByte();
                    const value = this.chunk.readConstant(@intCast(idx));
                    std.debug.print("Read constant: {d}\n", .{value});
                },
            }
        }
    }
};
