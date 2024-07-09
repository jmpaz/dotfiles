import logging

from libqtile import bar, layout
from libqtile.config import Match, Screen

from .colors import colors
from .widgets import load_widgets

layout_theme = {
    "border_width": 2,
    "margin": 7,
    "border_focus": colors["color11"],
    "border_normal": colors["color0"],
}
layouts = [
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Columns(**layout_theme),
    layout.Max(**layout_theme),
    # layout.Floating(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.Spiral(
    #     min_pane_ratio=0.70, ratio=0.52, new_client_position="bottom", **layout_theme
    # ),
    # layout.Bsp(**layout_theme),
    # layout.Stack(num_stacks=2),
    # layout.Matrix(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]


float_titles = [
    "Characters",
    "Bluetooth",
    "pinentry",
]
float_classes = [
    "nitrogen",
    "pavucontrol",
    "Arandr",
    "feh",
    "mpv",
    "obs",
]
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        *[Match(title=title) for title in float_titles],
        *[Match(wm_class=wm_class) for wm_class in float_classes],
    ],
    fullscreen_border_width=0,
    border_width=4,
    border_focus=colors["color11"],
    border_normal=colors["color1"],
)


screens = [
    Screen(
        top=bar.Bar(
            widgets=load_widgets(1),
            background=colors["transparent_bg"],
            margin=0,
            size=30,
            opacity=0.9,
        ),
    ),
    Screen(
        bottom=bar.Bar(
            widgets=load_widgets(1),
            background=colors["transparent_bg"],
            margin=0,
            size=30,
            opacity=0.9,
        ),
    ),
]
