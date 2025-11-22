const std = @import("std");
const config = @import("./config.zig").config;

pub const Options = struct {
    latitude: f64 = config.initial_latitude,
    longitude: f64 = config.initial_longitude,
    zoom: ?f64 = config.initial_zoom,
    width: ?u64 = null,
    height: ?u64 = null,
    braille: bool = config.use_braille,
    headless: bool = config.headless,
    tile_source: []const u8 = config.source,
    style_file: []const u8 = config.style_file,
};

fn foundArgs(args: *Options, arg_name: []const u8, val: []const u8) !bool {
    inline for (@typeInfo(Options).@"struct".fields) |field| {
        const flag_name = "--" ++ field.name;
        if (std.mem.eql(u8, arg_name, flag_name)) {
            switch (field.type) {
                f64 => @field(args, field.name) = try std.fmt.parseFloat(f64, val),
                ?f64 => @field(args, field.name) = try std.fmt.parseFloat(f64, val),
                u32 => @field(args, field.name) = try std.fmt.parseInt(u64, val, 10),
                ?u32 => @field(args, field.name) = try std.fmt.parseInt(u64, val, 10),
                bool => @field(args, field.name) = std.mem.eql(u8, val, "true"),
                []const u8 => @field(args, field.name) = val,
                else => return error.InvalidArgument,
            }
            return true;
        }
    }
    return false;
}

pub fn parseArgs() !Options {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var parsedArgs = try std.process.argsWithAllocator(allocator);
    defer parsedArgs.deinit();

    _ = parsedArgs.skip();

    var args: Options = .{};

    while (parsedArgs.next()) |parsedArg| {
        if (!std.mem.startsWith(u8, parsedArg, "--")) {
            return error.InvalidArgument;
        }
        var arg_and_val = std.mem.splitScalar(u8, parsedArg, '=');
        const arg = arg_and_val.next() orelse return error.InvalidArgument;
        const val = arg_and_val.next() orelse return error.InvalidArgument;
        if (!try foundArgs(&args, arg, val)) {
            return error.InvalidArgument;
        }
    }
    return args;
}
