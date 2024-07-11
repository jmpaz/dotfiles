import json
import logging
import os


def log_colors(colors):
    qtile_logger = logging.getLogger("libqtile")
    qtile_logger.setLevel(logging.INFO)
    for color in colors:
        qtile_logger.info(f"{color}: {colors[color]}")


def compute_transparent_bg(background_color, opacity=0.5):
    def hex_to_rgba(hex_color):
        return tuple(int(hex_color[i : i + 2], 16) for i in (1, 3, 5)) + (
            int(hex_color[7:9], 16) if len(hex_color) > 7 else 255,
        )

    def rgba_to_hex(rgba):
        return "#{:02x}{:02x}{:02x}{:02x}".format(*rgba)

    bg_rgba = hex_to_rgba(background_color)

    # adjust alpha channel
    transparent_rgba = bg_rgba[:3] + (int(255 * opacity),)

    return rgba_to_hex(transparent_rgba)


def get_colors():
    path = "~/.cache/wal/colors.json"
    with open(os.path.expanduser(path), "r") as f:
        wal_data = json.load(f)
        colors = wal_data["colors"]

    # i3 color names
    colors.update(
        {
            "focused_border": colors["color6"],
            "focused_background": colors["color0"],
            "focused_text": colors["color7"],
            "focused_indicator": colors["color4"],
            "focused_child_border": colors["color1"],
            "focused_inactive_border": colors["color0"],
            "focused_inactive_bg": colors["color0"],
            "focused_inactive_text": colors["color2"],
            "unfocused_border": colors["color0"],
            "unfocused_bg": colors["color0"],
            "unfocused_text": colors["color8"],
            "urgent_border": colors["color3"],
            "urgent_bg": colors["color1"],
            "urgent_text": colors["color7"],
            "background": colors["color0"],
            "active_tab_bg": colors["color5"],
            "active_tab_fg": colors["color15"],
            "active_tab_fg_light": colors["color0"],
        }
    )
    colors["transparent_bg"] = compute_transparent_bg(colors["background"])
    # log_colors(colors)
    return colors


colors = get_colors()
