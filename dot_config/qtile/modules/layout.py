import logging

from libqtile import bar, layout
from libqtile.config import Match, Screen

from .colors import colors
from .widgets import load_widgets

layout_theme = {
    "border_focus": colors["focused_border"],
    "border_normal": colors["unfocused_border"],
    "border_width": 4,
    "margin": 2,
}

primary_layouts = [
    layout.Columns(
        num_columns=2,
        insert_position=1,
        margin_on_single=10,
        single_border_width=layout_theme["border_width"],
        **layout_theme,
    ),
    layout.MonadTall(**layout_theme),
    layout.Plasma(**layout_theme),
    layout.Max(**{"border_width": 0}),
]
secondary_layouts = [
    layout.MonadWide(**layout_theme),
    layout.Plasma(**layout_theme),
    layout.Max(**{"border_width": 0}),
]
layouts = primary_layouts + secondary_layouts


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
    border_width=5,
    border_focus=colors["focused_border"],
    border_normal=colors["unfocused_border"],
)


screens = [
    Screen(
        top=bar.Bar(
            widgets=load_widgets(0),
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
