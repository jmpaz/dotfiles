from modules.groups import groups, scratchpad
from modules.hooks import *
from modules.keys import keys, mouse
from modules.layout import floating_layout, layouts, screens
from modules.widgets import load_widgets

groups.append(scratchpad)


dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "qtile"
