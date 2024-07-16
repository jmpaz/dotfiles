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

layouts = [
    layout.MonadTall(num_columns=2, **layout_theme),
    layout.Columns(
        num_columns=2,
        insert_position=1,
        margin_on_single=10,
        single_border_width=layout_theme["border_width"],
        **layout_theme,
    ),
    layout.Plasma(**layout_theme),
    layout.Max(**{"border_width": 0}),
    # layout.Tile(**layout_theme),
    # Bonsai(
    #     **{
    #         "L1.tab_bar.hide_when": "always",
    #         "L2.window.margin": [4, 2, 4, 2],
    #         "window.border_size": 4,
    #         "window.border_color": colors["unfocused_border"],
    #         "window.active.border_color": colors["focused_border"],
    #         "window.default.add_mode": "match_previous",
    #         "auto_cwd_for_terminals": True,
    #         "tab_bar.height": 20,
    #         "tab_bar.tab.fg_color": colors["unfocused_text"],
    #         "tab_bar.tab.bg_color": colors["background"],
    #         "tab_bar.tab.active.fg_color": colors["active_tab_fg_light"],
    #         # "tab_bar.tab.active.fg_color": colors["active_tab_fg"],
    #         "tab_bar.tab.active.bg_color": colors["active_tab_bg"],
    #         "container_select_mode.border_color": colors["urgent_border"],
    #     },
    # ),
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
    border_width=5,
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
