import json
import logging
import os
from pathlib import Path
from PIL import Image
import random
from libqtile import qtile


WALLPAPER_DIR = os.path.expanduser("~/.local/share/wallpapers")

wallpapers = {}
compatible_wallpapers = {}
current_wallpaper_indices = {}


def initialize_wallpapers(qtile):
    global wallpapers, compatible_wallpapers, current_wallpaper_indices
    wallpapers.clear()
    compatible_wallpapers.clear()
    current_wallpaper_indices.clear()

    wallpapers = get_wallpapers()

    for i in range(len(qtile.screens)):
        compatible_wallpapers[i] = filter_wallpapers(wallpapers, i)
        current_wallpaper_indices[i] = 0
        set_wallpaper(qtile, display=i)


def get_wallpapers(wallpaper_dir: str = WALLPAPER_DIR) -> dict:
    wallpapers = {}
    for root, _, files in os.walk(wallpaper_dir):

        if root.startswith(os.path.join(wallpaper_dir, "queue")):
            continue  # skip files in queue folder

        for file in files:
            if file.lower().endswith((".png", ".jpg", ".jpeg", ".bmp")):
                path = os.path.join(root, file)
                try:
                    with Image.open(path) as img:
                        width, height = img.size
                        aspect_ratio = width / height
                    wallpapers[path] = {
                        "path": path,
                        "filesize": os.path.getsize(path),
                        "resolution": (width, height),
                        "aspect_ratio": aspect_ratio,
                    }
                except Exception as e:
                    logging.error(f"Error processing {path}: {str(e)}")
    return wallpapers


def filter_wallpapers(wallpapers: dict, display: int, min_delta: float = 0.1) -> dict:
    compatible_wallpapers = {}
    screen = qtile.screens[display]
    screen_width = screen.width
    screen_height = screen.height
    screen_aspect_ratio = screen_width / screen_height

    for path, info in wallpapers.items():
        wallpaper_aspect_ratio = info["aspect_ratio"]

        # check orientation
        if (screen_aspect_ratio > 1 and wallpaper_aspect_ratio > 1) or (
            screen_aspect_ratio < 1 and wallpaper_aspect_ratio < 1
        ):

            # check resolution
            wallpaper_width, wallpaper_height = info["resolution"]
            width_ratio = wallpaper_width / screen_width
            height_ratio = wallpaper_height / screen_height

            if width_ratio > 1 and height_ratio > 1:
                compatible_wallpapers[path] = info
            elif abs(1 - width_ratio) <= min_delta and abs(1 - height_ratio) <= min_delta:
                compatible_wallpapers[path] = info

    return compatible_wallpapers


def set_wallpaper(qtile, cycle_direction: str = "", image_path: str = "", display: int = None):
    global compatible_wallpapers, current_wallpaper_indices
    if compatible_wallpapers == {}:
        initialize_wallpapers(qtile)

    if display is None:
        display = qtile.current_screen.index

    screen = qtile.screens[display]

    if not compatible_wallpapers.get(display):
        logging.error(f"No compatible wallpapers found for display {display}")
        return

    wallpaper_list = list(compatible_wallpapers[display].keys())

    if image_path:
        if image_path in wallpaper_list:
            new_wallpaper = image_path
        else:
            logging.error(
                f"Specified image {image_path} is not compatible with display {display}"
            )
            return
    elif cycle_direction:
        current_index = current_wallpaper_indices[display]
        if cycle_direction == "next":
            new_index = (current_index + 1) % len(wallpaper_list)
        elif cycle_direction == "prev":
            new_index = (current_index - 1) % len(wallpaper_list)
        else:  # random
            new_index = random.randint(0, len(wallpaper_list) - 1)
        new_wallpaper = wallpaper_list[new_index]
        current_wallpaper_indices[display] = new_index
    else:
        new_index = random.randint(0, len(wallpaper_list) - 1)
        new_wallpaper = wallpaper_list[new_index]
        current_wallpaper_indices[display] = new_index

    screen.cmd_set_wallpaper(new_wallpaper, mode="fill")
    logging.info(f"Set wallpaper for display {display}: {new_wallpaper}")


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
