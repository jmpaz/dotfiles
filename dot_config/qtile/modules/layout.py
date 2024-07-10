import logging

from qtile_bonsai import Bonsai

from libqtile import bar, layout
from libqtile.config import Match, Screen

from .colors import colors
from .widgets import load_widgets

layouts = [
    Bonsai(
        **{
            "L1.tab_bar.hide_when": "always",
            "window.margin": [4, 2, 4, 2],
            "window.border_size": 3,
            "window.border_color": colors["unfocused_border"],
            "window.active.border_color": colors["focused_border"],
            "window.default.add_mode": "match_previous",
            "auto_cwd_for_terminals": True,
            "tab_bar.height": 20,
            "tab_bar.tab.bg_color": colors["background"],
            "tab_bar.tab.fg_color": colors["unfocused_text"],
            "tab_bar.tab.active.bg_color": colors["focused_indicator"],
            "tab_bar.tab.active.fg_color": colors["color15"],
            "container_select_mode.border_color": colors["urgent_border"],
        },
    ),
    layout.Max(**{"border_width": 0}),
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
    border_width=3,
    border_focus=colors["focused_border"],
    border_normal=colors["unfocused_border"],
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
