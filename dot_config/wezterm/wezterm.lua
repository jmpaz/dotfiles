local wezterm = require("wezterm")
local act = wezterm.action

-- Load from module
local ssh_config = require("ssh")

-- Base config
local config = {
	enable_wayland = false,
	color_scheme = "Rosé Pine (base16)",

	default_cursor_style = "BlinkingBar",
	animation_fps = 60,
	font = wezterm.font_with_fallback({
		{ family = "Geist Mono" },
		{ family = "Monaspace Argon" },
	}),
	font_size = 15,

	inactive_pane_hsb = {
		saturation = 0.55,
		brightness = 0.45,
	},

	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	window_decorations = "RESIZE",
	window_background_opacity = 0.9,

	window_padding = {
		top = "0cell",
		left = 20,
		right = 15,
		bottom = 0,
	},

	keys = {
		{ key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },
		{ key = "t", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
		{ key = "w", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
		{ key = "m", mods = "SUPER", action = act.DisableDefaultAssignment },
		{ key = "n", mods = "SUPER", action = act.DisableDefaultAssignment },
		{ key = "t", mods = "SUPER", action = act.DisableDefaultAssignment },
		{ key = "w", mods = "SUPER", action = act.DisableDefaultAssignment },
		{ key = "c", mods = "SUPER", action = act.DisableDefaultAssignment },
		{ key = "v", mods = "SUPER", action = act.DisableDefaultAssignment },
	},

	key_tables = {},

	unix_domains = { { name = "unix" } },
}

-- Merge ssh_config into main config
for k, v in pairs(ssh_config) do
	config[k] = v
end

return config
