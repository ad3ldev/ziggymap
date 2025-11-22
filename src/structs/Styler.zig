const std = @import("std");

const Style = struct { name: []u8, layers: []Layer, constants: []u8 };

const Layer = struct { ref: []u8 };

const Styler = struct {
    style_by_id: i64,
    style_by_layer: []Layer,
    base: []u8,
    name: []u8,
    style: Style,

    pub fn init(self: *Styler, style_by_id: i64, style_by_layer: []Layer, base: []u8, name: []u8, style: Style) Styler {
        return self{
            .style_by_id = style_by_id,
            .style_by_layer = style_by_layer,
            .base = base,
            .name = name,
            .style = style,
        };
    }
    fn checkConstants(self: Styler) noreturn {
        if (self.style.constants) {
            self.replaceConstants(self.style.constants, self.style.layers);
        }
    }

    fn retreiveLayers(self: Styler) noreturn {
        for (self.style.layers) |layer| {
            if (layer.ref and self.style_by_id) {
                for ([_]u8{ "type", "source-layer", "minzoom", "maxzoom", "filter" }) |ref| {
                    if (self.style_by_id and !self.layer[ref]) {
                        layer.ref = self.style_by_id;
                    }
                }
            }
        }
    }

    pub fn getStyleFor(self: Styler, feature: []u8) ?Style {
        if (!self.style_by_layer) {
            return null;
        }
        for (self.style_by_layer) |layer| {
            if (layer.appliesTo(feature)) {
                return layer;
            }
        }
        return null;
    }

    fn replaceConstants(constants: []u8, tree: []u8) noreturn {
        for (tree) |id| {
            const node: u64 = id;
            switch (@TypeOf(node)) {
                []u8 => if (node.name) {
                    continue;
                },
                []u8 => if (node[0] == '@') {
                    tree = constants[node];
                },
            }
        }
    }

    // fn compileFilter(self: Styler, filter: []u8) bool {
    // var filters: []u8 = "";
    // switch (if (filter != null) filter[0] else void) {
    //   'all' => {
    //     filter = filter[0..1];
    //     filters = fn () bool {
    //       return filter.map((sub) => this._compileFilter(sub));
    //     }).call(this);
    //     return (feature) => !!filters.find((appliesTo) => {
    //       return !appliesTo(feature);
    //     });
    //         }
    //   case 'any':
    //     filter = filter.slice(1);
    //     filters = (() => {
    //       return filter.map((sub) => this._compileFilter(sub));
    //     }).call(this);
    //     return (feature) => !!filters.find((appliesTo) => {
    //       return appliesTo(feature);
    //     });
    //   case 'none':
    //     filter = filter.slice(1);
    //     filters = (() => {
    //       return filter.map((sub) => this._compileFilter(sub));
    //     }).call(this);
    //     return (feature) => !filters.find((appliesTo) => {
    //       return !appliesTo(feature);
    //     });
    //   case '==':
    //     return (feature) => feature.properties[filter[1]] === filter[2];
    //   case '!=':
    //     return (feature) => feature.properties[filter[1]] !== filter[2];
    //   case 'in':
    //     return (feature) => !!filter.slice(2).find((value) => {
    //       return feature.properties[filter[1]] === value;
    //     });
    //   case '!in':
    //     return (feature) => !filter.slice(2).find((value) => {
    //       return feature.properties[filter[1]] === value;
    //     });
    //   case 'has':
    //     return (feature) => !!feature.properties[filter[1]];
    //   case '!has':
    //     return (feature) => !feature.properties[filter[1]];
    //   case '>':
    //     return (feature) => feature.properties[filter[1]] > filter[2];
    //   case '>=':
    //     return (feature) => feature.properties[filter[1]] >= filter[2];
    //   case '<':
    //     return (feature) => feature.properties[filter[1]] < filter[2];
    //   case '<=':
    //     return (feature) => feature.properties[filter[1]] <= filter[2];
    //   default:
    //     return () => true;
    // }
    // }

    // }
};
