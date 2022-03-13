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
            .{ .name = "btn2", .text = "Sarmale reci qqjga", .flex_factor = 0 },
        },
    } });

    const button1 = layout.findChildOfType(Button, "btn1").?;
    const button2 = layout.findChildOfType(Button, "btn2").?;

    const layer_surface = try app.createLayerSurface(layout.widget, .{ .top = true, .right = true, .left = true });
    // _ = try app.createWindow(layout.widget);


    var b = try Button.init(app);
    var rects = try layout.getChildRectTrace(button2.widget);
    defer rects.deinit();

    // // std.debug.print("{}\n", .{rects});

    const s = try waq.Popover.init(
        app,
        b.widget,
        rects.items,
        .{ .layer_surface = layer_surface },
    );

    button1.onClick = Widget.Callback.init(
        button1,
        s,
        struct {
            fn click(_: *Button, ss: *waq.Popover) void {
                ss.toggle() catch unreachable;
            }
        }.click,
    );

    try app.run();
}
