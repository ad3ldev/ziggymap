const std = @import("std");
const config = @import("../helpers/config.zig").config;

const BrailleMap = [4][2]u8{ .{ 0x1, 0x8 }, .{ 0x2, 0x10 }, .{ 0x4, 0x20 }, .{ 0x40, 0x80 } };

const AsciiMapItem = struct {
    char: u21,
    mask: u8,
};

const ascii_map = [_]AsciiMapItem{
    .{},
};
// '▬': [2+32, 4+64],
// '¯': [1+16],
// '▀': [1+2+16+32],
// '▄': [4+8+64+128],
// '■': [2+4+32+64],
// '▌': [1+2+4+8],
// '▐': [16+32+64+128],
// '▓': [1+4+32+128, 2+8+16+64],
// '█': [255],
//
//
const term_reset = "\x1B[39;49m";

const BrailleBuffer = struct {
    brailleMap: [4][2]u8 = BrailleMap,

    pixelBuffer: []?u21,
    foregroundBuffer: []?u21,
    backgroundBuffer: []?u21,

    charBuffer: []?u21,
    ascii_to_braille: []?u21,

    globalBackgroud: []?u21,

    width: f64,
    height: f64,

    pub fn init(self: *BrailleBuffer, allocator: std.mem.Allocator, width: f64, height: f64) !BrailleBuffer {
        const size = width * height / 8;
        self.pixelBuffer = try allocator.alloc(u21, size);
        self.foregroundBuffer = try allocator.alloc(u21, size);
        self.backgroundBuffer = try allocator.alloc(u21, size);
        self.mapBraille();
        self.clear();
        return self;
    }
    pub fn clear(self: *BrailleBuffer) void {
        self.pixelBuffer = std.mem.zerros(self.backgroundBuffer.len);
        self.backgroundBuffer = std.mem.zerros(self.backgroundBuffer.len);
        self.backgroundBuffer = std.mem.zerros(self.backgroundBuffer.len);
        self.charBuffer = []u8;
    }
    pub fn setGlobalBackground(self: *BrailleBuffer, background: anytype) void {
        self.globalBackgroud = background;
    }
    pub fn setBackground(self: *BrailleBuffer, x: f64, y: f64, color: [7]u8) void {
        if (0 <= x and x < self.width and 0 <= y and y < self.height) {
            const idx = self.project(x, y);
            self.backgroundBuffer[idx] = color;
        }
    }
    pub fn setPixel(self: *BrailleBuffer, x: f64, y: f64, color: [7]u8) void {
        const cb = struct {
            fn cb(idx: usize, mask: u8) void {
                self.pixelBuffer[idx] |= mask;
                self.foregroundBuffer[idx] = color;
            }
        }.cb;
        self.locate(x, y, cb);
    }
    pub fn unsetPixel(self: *BrailleBuffer, x: f64, y: f64) void {
        const cb = struct {
            fn cb(idx: usize, mask: u8) void {
                self.pixelBuffer[idx] &= ~mask;
            }
        }.cb;
        self.locate(x, y, cb);
    }
    pub fn frame(self: *BrailleBuffer) []u21 {
        const output: []u21 = {};
        var current_color: [7]?u8 = null;
        var skip = 0;

        for (0..self.height / 4) |y| {
            skip = 0;

            for (0..self.width / 2) |x| {
                const idx = y * self.width / 2 + x;
                if (idx != 0 and x == 0) {
                    try output.append(config.delimiter);
                }
                const color_code = self.termColor(self.foreground_buffer[idx], self.background_buffer[idx]);

                if (current_color != color_code) {
                    current_color = color_code;
                    try output.append(current_color);
                }

                const char = self.char_buffer[idx];
                if (char != 0) {
                    //TODO: change to stringWidth
                    skip += 1;
                    if (skip + x < self.width / 2) {
                        try output.append(char);
                    }
                } else {
                    if (skip == 0) {
                        if (config.use_braille) {
                            const braille_char = @as(u21, 0x2800 + self.pixel_buffer[idx]);
                            try output.append(braille_char);
                        } else {
                            try output.append(self.ascii_to_braille[self.pixel_buffer[idx]]);
                        }
                    } else {
                        skip -= 1;
                    }
                }
            }
        }
    }
    pub fn setChar(self: *BrailleBuffer, char: u8, x: f64, y: f64, color: [7]u8) void {
        if (0 <= x and x < self.width and 0 <= y and y < self.height) {
            const idx = self.project(x, y);
            self.charBuffer[idx] = char;
            self.foregroundBuffer[idx] = color;
        }
    }
    pub fn writeText(self: *BrailleBuffer, text: []u8, x: f64, y: f64, color: [7]u8, center: bool) void {
        if (center) {
            x -= text.length / 2 + 1;
        }
        for (text.len) |i| {
            self.setChar(text.charAt(i), x + i * 2, y, color);
        }
    }

    fn project(self: *BrailleBuffer, x: f64, y: f64) u64 {
        return (x >> 1) + (self.width >> 1) * (y >> 2);
    }
    fn locate(self: *BrailleBuffer, x: f64, y: f64, cb: anytype) void {
        if (!((0 <= x and x < self.width) and (0 <= y and y < self.height))) {
            return;
        }
        const idx = self.project(x, y);
        const mask = self.brailleMap[y & 3][x & 1];
        return cb(idx, mask);
    }
    fn termColor(self: *BrailleBuffer, foreground: []u21, background: []u21) []u8 {
        background |= self.global_background;
        if (foreground.len != 0 and background.len != 0) {
            return try std.fmt.allocPrint(self.allocator, "\x1B[38;5;{d};48;5;{d}m", .{ foreground, background });
        } else if (foreground != 0) {
            return try std.fmt.allocPrint(self.allocator, "\x1B[49;38;5;{d}m", .{foreground});
        } else if (background.len != 0) {
            return try std.fmt.allocPrint(self.allocator, "\x1B[39;48;5;{d}m", .{background});
        } else {
            return term_reset;
        }
    }
    // TOOD: Implement
    fn mapBraille(self: *BrailleBuffer) void {}
};
