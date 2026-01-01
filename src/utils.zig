const std = @import("std");

pub const TermCodes = struct {
    pub const Style = enum {
        // --- Styles ---
        reset,
        bold,
        dim,
        italic,
        underline,
        blink,
        invert,
        hidden,
        strikethrough,
        // --- Foreground ---
        black,
        red,
        green,
        yellow,
        blue,
        magenta,
        cyan,
        white,
        gray,
        bright_red,
        bright_green,
        bright_yellow,
        bright_blue,
        bright_magenta,
        bright_cyan,
        bright_white,
        // --- Background ---
        bg_black,
        bg_red,
        bg_green,
        bg_yellow,
        bg_blue,
        bg_magenta,
        bg_cyan,
        bg_white,
        bg_gray,
        bg_bright_red,
        bg_bright_green,
        bg_bright_yellow,
        bg_bright_blue,
        bg_bright_magenta,
        bg_bright_cyan,
        bg_bright_white,

        pub fn asAnsi(comptime self: Style) []const u8 {
            return switch (self) {
                // Styles
                .reset => "\x1b[0m",
                .bold => "\x1b[1m",
                .dim => "\x1b[2m",
                .italic => "\x1b[3m",
                .underline => "\x1b[4m",
                .blink => "\x1b[5m",
                .invert => "\x1b[7m",
                .hidden => "\x1b[8m",
                .strikethrough => "\x1b[9m",

                // Foreground
                .black => "\x1b[30m",
                .red => "\x1b[31m",
                .green => "\x1b[32m",
                .yellow => "\x1b[33m",
                .blue => "\x1b[34m",
                .magenta => "\x1b[35m",
                .cyan => "\x1b[36m",
                .white => "\x1b[37m",

                // Foreground Bright
                .gray => "\x1b[90m",
                .bright_red => "\x1b[91m",
                .bright_green => "\x1b[92m",
                .bright_yellow => "\x1b[93m",
                .bright_blue => "\x1b[94m",
                .bright_magenta => "\x1b[95m",
                .bright_cyan => "\x1b[96m",
                .bright_white => "\x1b[97m",

                // Background
                .bg_black => "\x1b[40m",
                .bg_red => "\x1b[41m",
                .bg_green => "\x1b[42m",
                .bg_yellow => "\x1b[43m",
                .bg_blue => "\x1b[44m",
                .bg_magenta => "\x1b[45m",
                .bg_cyan => "\x1b[46m",
                .bg_white => "\x1b[47m",

                // Background Bright
                .bg_gray => "\x1b[100m",
                .bg_bright_red => "\x1b[101m",
                .bg_bright_green => "\x1b[102m",
                .bg_bright_yellow => "\x1b[103m",
                .bg_bright_blue => "\x1b[104m",
                .bg_bright_magenta => "\x1b[105m",
                .bg_bright_cyan => "\x1b[106m",
                .bg_bright_white => "\x1b[107m",
            };
        }
    };

    pub fn paint(comptime styles: anytype, value: anytype, comptime fmt: []const u8) Painted(@TypeOf(value), fmt, true) {
        comptime var color_str: []const u8 = "";
        const T = @TypeOf(styles);

        if (T == Style) {
            color_str = styles.asAnsi();
        } else {
            inline for (styles) |s| {
                if (@TypeOf(s) != Style) @compileError("paint() expects TermCodes.Style or a tuple of them.");
                color_str = color_str ++ comptime s.asAnsi();
            }
        }
        return .{ .color = color_str, .value = value };
    }

    pub fn Painted(comptime T: type, comptime fmt: []const u8, comptime enabled: bool) type {
        return struct {
            color: []const u8,
            value: T,

            pub fn format(this: @This(), writer: *std.io.Writer) !void {
                if (enabled) try writer.writeAll(this.color);
                try writer.print(fmt, .{this.value});
                if (enabled) try writer.writeAll(comptime Style.reset.asAnsi());
            }

            pub fn setEnabled(this: @This(), comptime new_enabled: bool) Painted(T, fmt, new_enabled) {
                return .{
                    .color = this.color,
                    .value = this.value,
                };
            }
        };
    }
};
