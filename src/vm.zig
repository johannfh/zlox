const builtin = @import("builtin");
const std = @import("std");
const assert = std.debug.assert;

const ch = @import("chunk.zig");
const Chunk = ch.Chunk;
const Opcode = ch.Opcode;
const value_mod = @import("value.zig");
const Value = value_mod.Value;

const is_safe = builtin.mode == .Debug or builtin.mode == .ReleaseSafe;

pub const InterpretError = error{
    CompileError,
    UnknownOpcode,
    IpOob,
    StackOverflow,
    StackUnderflow,
};

pub const VM = struct {
    // -- Execution Chunk --
    chunk: *const Chunk,

    // -- Instruction Pointer --
    ip: [*]const u8,
    ip_end: [*]const u8,
    ip_start: [*]const u8,

    // -- Stack Pointer --
    /// Pointer to the current top of the stack, i.e. the position of the *next* value.
    sp: [*]Value,
    /// Pointer to the lowest value of the stack.
    sp_start: [*]Value,
    /// Pointer to the
    sp_end: [*]Value,

    pub fn init(c: *const Chunk, stack: []Value) @This() {
        // calculate ip bounds
        const ip = c.code.items.ptr;
        const ip_start = ip;
        const ip_end = ip + c.count();

        // calculate sp bounds
        const sp = stack.ptr;
        const sp_start = sp;
        const sp_end = sp + stack.len;

        return .{
            .chunk = c,
            .ip = ip,
            .ip_start = ip_start,
            .ip_end = ip_end,
            .sp = sp,
            .sp_start = sp_start,
            .sp_end = sp_end,
        };
    }

    inline fn readByte(this: *@This()) InterpretError!u8 {
        if (@intFromPtr(this.ip) < @intFromPtr(this.ip_start) or @intFromPtr(this.ip) >= @intFromPtr(this.ip_end)) {
            return error.IpOob;
        }
        const byte = this.ip[0];
        this.ip += 1;
        return byte;
    }

    fn push(this: *@This(), value: Value) InterpretError!void {
        if (@intFromPtr(this.sp) >= @intFromPtr(this.sp_end)) {
            return error.StackOverflow;
        }
        this.sp[0] = value;
        this.sp += 1;
    }

    fn pop(this: *@This()) InterpretError!Value {
        if (@intFromPtr(this.sp) < @intFromPtr(this.sp_start)) {
            return error.StackUnderflow;
        }
        this.sp -= 1;
        return this.sp[0];
    }

    inline fn binaryOp(this: *@This(), comptime op: []const u8) InterpretError!void {
        const b = try this.pop();
        const a = try this.pop();
        const result: Value = try @field(Value, op)(a, b);
        std.debug.print(
            "Calculating {s}({f}, {f}) => {f}\n",
            .{ op, a, b, result },
        );
        try this.push(result);
    }

    pub fn run(this: *@This()) InterpretError!void {
        while (true) {
            const instruction = try this.readByte();
            const opcode = std.enums.fromInt(Opcode, instruction) orelse {
                return error.UnknownOpcode;
            };
            std.debug.print("Executing {f} at offset 0x{X}\n", .{ opcode, this.ip - 1 - this.ip_start });

            switch (opcode) {
                .OP_RETURN => {
                    std.debug.print("Returning\n", .{});
                    return;
                },
                .OP_CONSTANT => {
                    const idx = try this.readByte();
                    const value = this.chunk.readConstant(@intCast(idx));
                    std.debug.print(
                        "Pushing constant {d}: {f}\n",
                        .{ idx, value },
                    );
                    try this.push(value);
                },
                .OP_ADD => try this.binaryOp("add"),
                .OP_SUBTRACT => try this.binaryOp("subtract"),
                .OP_MULTIPLY => try this.binaryOp("multiply"),
                .OP_DIVIDE => try this.binaryOp("divide"),
            }
        }
    }

    pub fn format(this: *const @This(), writer: anytype) !void {
        const ip_offset = this.ip - this.ip_start;
        const sp_offset = this.sp - this.sp_start;
        try writer.print("VM {{ instruction pointer offset: {}, stack pointer offset: {}, sp: {*}, sp_start: {*}, sp_end: {*} }}", .{
            ip_offset,
            sp_offset,
            this.sp,
            this.sp_start,
            this.sp_end,
        });
    }
};
