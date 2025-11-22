const Config = struct {
    language: []u8 = "en",
    // TODO:
    // style_file
    initial_zoom: ?u8 = null,
    max_zoom: u8 = 18,
    zoom_step: u8 = 0.2,

    // TODO:
    // initial_latitude
    // initial_longitude
    simplify_polylines: bool = false,
    use_braille: bool = true,

    // TODO:
    // source
    persist_downloaded_tiles: bool = true,
    tile_range: u8 = 14,
    project_size: u8 = 256,
    label_margin: u8 = 5,

    layers: struct { house_number_label: struct {
        margin: u8 = 4,
    }, poi_label: struct {
        cluster: bool = true,
        margin: u8 = 5,
    }, place_label: struct {
        cluster: bool = true,
    }, state_label: struct {
        cluster: bool = true,
    } },

    // TODO:
    // input
    // output
    //
    headless: bool = false,
    delimeter: []u8 = "\n\r",
    poi_marker: u8 = "*",
};

pub const config: Config = Config;

