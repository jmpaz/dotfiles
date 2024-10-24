import logging

from libqtile import bar, layout
from libqtile.config import Match, Screen

from .theme import colors
from .widgets import load_widgets
from .platform import get_number_of_screens

layout_theme = {
    "border_focus": colors["focused_border"],
    "border_normal": colors["unfocused_border"],
    "border_width": 2,
    "margin": 8,
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
]

secondary_layouts = [
    layout.MonadWide(align=1, ratio=0.65, **layout_theme),
    layout.VerticalTile(**layout_theme),
]

shared_layouts = [layout.Plasma(**layout_theme), layout.Max(**{"border_width": 0})]

num_screens = get_number_of_screens()
if num_screens == 1:
    layouts = primary_layouts + shared_layouts
else:
    layouts = primary_layouts + secondary_layouts + shared_layouts

float_titles = [
    "Characters",
    "Bluetooth Devices",
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
        *layout.Floating.default_float_rules,
        *[Match(title=title) for title in float_titles],
        *[Match(wm_class=wm_class) for wm_class in float_classes],
    ],
    fullscreen_border_width=0,
    border_width=2,
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
    )
]

if num_screens > 1:
    screens.append(
        Screen(
            bottom=bar.Bar(
                widgets=load_widgets(1),
                background=colors["transparent_bg"],
                margin=0,
                size=30,
                opacity=0.9,
            ),
        )
    )
