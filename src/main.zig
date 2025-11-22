const std = @import("std");
const options = @import("./helpers/options.zig");
const ziggyMap = @import("./structs/Ziggymap.zig").ZiggyMap;

pub fn main() !void {
    const args = options.parseArgs() catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };
    const ziggy_map = ziggyMap.init(args);
    std.debug.print("{any}\n", .{ziggy_map});
}
