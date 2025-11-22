const Config = struct {
    language: []u8 = "en",

    /// TODO: use the new one
    /// source: []u8 = "https://api.maptiler.com",
    source: []u8 = "http://mapscii.me/",

    style_file: []u8 = "../styles/dark.json",

    initial_zoom: ?u8 = null,
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

    layers: .{
        .house_number_label = .{
            .margin = 4,
        },
        .poi_label = .{
            .cluster = true,
            .margin = 5,
        },
        .place_label = .{
            .cluster = true,
        },
        .state_label = .{
            .cluster = true,
        },
    },

    // TODO:
    // input
    // output
    //
    headless: bool = false,

    delimeter: []u8 = "\n\r",

    poi_marker: u8 = "*",
};

pub const config: Config = Config;
