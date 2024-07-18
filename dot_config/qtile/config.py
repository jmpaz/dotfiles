from modules.groups import groups, scratchpad
from modules.hooks import *
from modules.keys import keys, mouse
from modules.layout import floating_layout, layouts, screens
from modules.widgets import load_widgets
from modules.platform import is_wayland, get_number_of_screens

groups.append(scratchpad)

num_screens = get_number_of_screens()
if num_screens == 1:
    layouts = layouts[:2]  # use only primary layouts
if num_screens == 1:
    screens = [screens[0]]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = True
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "qtile"

if is_wayland():
    wl_input_rules = {
        "type:touchpad": {
            "natural_scroll": True,
            "tap": True,
            "tap_button_map": "lrm",
            "accel_profile": "flat",
        }
    }
