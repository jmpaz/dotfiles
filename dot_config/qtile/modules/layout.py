# from modules.colors import colors

from libqtile import layout
from libqtile.config import Match


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
    border_width=4,
    # single_border_width=2,
    ## border_focus=colors["highlight"],
    ## border_normal=colors["darkerForground"],
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        *[Match(title=title) for title in float_titles],
        *[Match(wm_class=wm_class) for wm_class in float_classes],
    ],
)


layout_theme = {
    "border_width": 2,
    "margin": 7,
    # "border_focus": colors["highlight"],
    # "border_normal": colors["darkerForground"],
    "border_focus": "#A9B1D6",
    "border_normal": "#2E3440",
    "single_border_width": 2,
}
layouts = [
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Columns(**layout_theme),
    floating_layout,
    layout.RatioTile(**layout_theme),
    layout.Max(**layout_theme),
    layout.Spiral(
        min_pane_ratio=0.70, ratio=0.52, new_client_position="bottom", **layout_theme
    ),
    # layout.Bsp(**layout_theme),
    # layout.Stack(num_stacks=2),
    # layout.Matrix(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]
