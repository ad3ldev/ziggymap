const config = @import("./config.zig").config;
const constants = @import("./constants.zig");
const math = @import("std").math;
const std = @import("std");

pub fn clamp(comptime T: type, num: T, min: T, max: T) T {
    if (num <= min) {
        return min;
    }
    if (num >= max) {
        return max;
    }
    return num;
}

pub fn baseZoom(zoom: f64) f64 {
    const a = @max(0.0, @floor(zoom));
    const b = @min(config.tile_range, a);
    return b;
}

pub fn tileSizeAtZoom(zoom: f64) f64 {
    const a = math.pow(f64, 2, zoom - baseZoom(zoom));
    const b = config.project_size * a;
    return b;
}

pub fn degToRad(angle: f64) f64 {
    const a = angle / 180;
    const b = a * math.pi;
    return b;
}

pub fn longLat2Title(long: f64, lat: f64, zoom: f64) struct { x: f64, y: f64, z: f64 } {
    const xA = long + 180;
    const xB = xA / 360;
    const xC = xB * math.pow(f64, 2, zoom);

    const yA = lat * math.pi / 180.0;
    const yB = math.tan(yA) + 1 / math.cos(yA);
    const yC = (1 - math.log(f64, 10, yB) / math.pi) / 2;
    const yD = yC * math.pow(f64, 2.0, zoom);

    return .{
        .x = xC,
        .y = yD,
        .z = zoom,
    };
}

pub fn tileToLongLat(x: f64, y: f64, zoom: f64) struct { long: f64, lat: f64 } {
    const n: f64 = math.pi - 2 * math.pi * y / math.pow(2, zoom);

    const longA = x / math.pow(2, zoom) * 360 - 180;

    const latA = math.exp(n) - math.exp(-n);
    const latB = math.atan(0.5 * latA);
    const latC = 180 / math.pi * latB;
    return .{ .long = longA, .lat = latC };
}

pub fn metersPerPixel(zoom: f64, lat: f64) f64 {
    const a = math.pow(f64, 2, zoom);
    const b = 256 * a;
    const c = math.cos(lat * math.pi / 180);
    const d = c * 2 * math.pi * constants.RADIUS;
    const e = (d) / b;
    return e;
}

pub fn hex_to_rgb(color: [7]u8) struct { r: u8, g: u8, b: u8 } {
    const r_hex = color[1..3];
    const g_hex = color[3..5];
    const b_hex = color[5..7];

    return .{
        .r = std.fmt.parseInt(r_hex, 16),
        .g = std.fmt.parseInt(g_hex, 16),
        .b = std.fmt.parseInt(b_hex, 16),
    };
}

pub fn toDigits(number: f64, digits: u64) u64 {
    const a = math.pow(u64, 10, digits);
    const b = math.pow(u64, 10, digits);
    const c = math.floor(number * a) / b;
    return c;
}

pub fn normalize(ll: struct { lat: f64, long: f64 }) struct { lat: f64, long: f64 } {
    if (ll.long < -180) {
        ll.long += 360;
    }
    if (ll.long > 180) {
        ll.lon -= 360;
    }

    if (ll.lat > 85.0511) {
        ll.lat = 85.0511;
    }
    if (ll.lat < -85.0511) {
        ll.lat = -85.0511;
    }

    return ll;
}

pub fn population(val: u64) u64 {
    var bits: u64 = 0;
    while (val > 0) {
        bits += val & 1;
        val >>= 1;
    }
    return bits;
}
