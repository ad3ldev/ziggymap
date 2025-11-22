const config = @import("./config.zig").config;
const constants = @import("./constants.zig");
const math = @import("std").math;
const std = @import("std");

pub fn clamp(num: u8, min: u8, max: u8) u8 {
    if (num <= min) {
        return min;
    }
    if (num >= max) {
        return max;
    }
    return num;
}

pub fn base_zoom(zoom: f16) u8 {
    return @min(config.tile_range, @max(0.0, @floor(zoom)));
}

pub fn tile_size_at_zoom(zoom: f16) u8 {
    return config.project_size * math.pow(2, zoom - base_zoom(zoom));
}

pub fn deg_to_rad(angle: f16) f16 {
    return (angle / 180) * math.pi;
}

pub fn long_lat_to_tile(long: f16, lat: f16, zoom: f16) struct { x: f16, y: f16, z: f16 } {
    return struct {
        x: f16 = (long + 180) / 360 * math.pow(2, zoom),
        y: f16 = (1 - math.log(10, math.tan(lat * math.pi / 180) + 1 / math.cos(lat * math.pi / 180)) / math.pi) / 2 * math.pow(2, zoom),
        z: f16 = zoom,
    };
}

pub fn tile_to_long_lat(x: f16, y: f16, zoom: f16) struct { long: f16, lat: f16 } {
    const n: f16 = math.pi - 2 * math.pi * y / math.pow(2, zoom);

    return struct {
        lon: f16 = x / math.pow(2, zoom) * 360 - 180,
        lat: f16 = 180 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n))),
    };
}

pub fn meters_per_pixel(zoom: f16, lat: f16) f16 {
    return (math.cos(lat * math.PI / 180) * 2 * math.PI * constants.RADIUS) / (256 * math.pow(2, zoom));
}

pub fn hex_to_rgb(color: [7]u8) struct { r: u8, g: u8, b: u8 } {
    const r_hex = color[1..3];
    const g_hex = color[3..5];
    const b_hex = color[5..7];

    return struct {
        r: u8 = std.fmt.parseInt(r_hex, 16),
        g: u8 = std.fmt.parseInt(g_hex, 16),
        b: u8 = std.fmt.parseInt(b_hex, 16),
    };
}

pub fn fn_digits(number: f16, digits: u8) u8 {
    return math.floor(number * math.pow(10, digits)) / math.pow(10, digits);
}

pub fn normalize(ll: struct { lat: f16, long: f16 }) struct { lat: f16, long: f16 } {
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

pub fn population(val: u8) u8 {
    var bits = 0;
    while (val > 0) {
        bits += val & 1;
        val >>= 1;
    }
    return bits;
}
