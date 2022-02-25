const std = @import("std");
const waq = @import("waq");
const Widget = waq.Widget;
const App = waq.App;
const Demo = waq.Demo;
const Button = waq.Button;
const Buffer = waq.Buffer;
const Size = waq.Size;
const Minmax = Size.Minmax;
const Flex = waq.Flex;
const Font = waq.Font;
const Color = waq.Color;
const Rect = waq.Rect;
const NamedColor = Color.NamedColor;
const print = std.debug.print;
const Callback = Widget.Callback;
const Label = waq.Label;

const util = waq.util;
var allocator = util.allocator;

pub fn main() anyerror!void {
    var app = try App.init(allocator);

    const layout = Widget.build(app, .{ Flex, .{
        .orientation = .Horizontal,
        .bg_color = comptime NamedColor.black.withAlpha(150),
    }, .{
        .{ Button, .{ .name = "btn1" } },
        .{ Button, .{ .name = "btn2" } },
        .{ Flex.Spacer, .{
            .name = "spacer",
            .flex_factor = 1,
            .bg_color = null,
        } },
        .{
            Label,
            .{ .name = "btn2", .text = "ABRACADABRA", .flex_factor = 0 },
        },
    } });

    // const btn = try Button.init(app);

    // const fm = layout.findChildOfType(FontMap, "font_map").?;
    // const spacer = layout.findChildOfType(Flex.Spacer, "spacer").?;

    _ = try app.createLayerSurface(layout.widget, .{ .top = true, .right = true, .left = true });
    // _ = try app.createWindow(layout.widget);

    try app.run();
}
