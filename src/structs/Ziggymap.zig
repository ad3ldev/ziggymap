const options = @import("../helpers/options.zig");

pub const ZiggyMap = struct {
    options: options.Options,

    pub fn init(passed_options: options.Options) ZiggyMap {
        return .{ .options = passed_options };
    }
};
