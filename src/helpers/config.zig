const Config = struct {
    language: *const [2:0]u8 = "en",

    /// TODO: use the new one
    /// source: []u8 = "https://api.maptiler.com",
    source: *const [18:0]u8 = "http://mapscii.me/",

    style_file: *const [19:0]u8 = "../styles/dark.json",

    initial_zoom: ?f64 = null,
    max_zoom: u64 = 18,
    zoom_step: f64 = 0.2,

    initial_latitude: f64 = 52.51298,
    initial_longitude: f64 = 13.42012,

    simplify_polylines: bool = false,

    use_braille: bool = true,

    persist_downloaded_tiles: bool = true,

    tile_range: u64 = 14,
    project_size: u64 = 256,

    label_margin: u64 = 5,

    layers: struct {
        house_number_label: struct {
            margin: u64 = 4,
        } = .{},
        poi_label: struct {
            cluster: bool = true,
            margin: u64 = 5,
        } = .{},
        place_label: struct {
            cluster: bool = true,
        } = .{},
        state_label: struct {
            cluster: bool = true,
        } = .{},
    } = .{},

    // TODO:
    // input
    // output
    //
    headless: bool = false,

    delimeter: *const [2:0]u8 = "\n\r",

    poi_marker: *const [1:0]u8 = "*",
};

pub const config: Config = .{};
