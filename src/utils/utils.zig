const config = @import("./config.zig").config;
const math = @import("std").math;

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
    return config.project_size * math.pow(u8, 2, zoom - base_zoom(zoom));
}
