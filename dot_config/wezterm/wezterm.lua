local wezterm = require("wezterm")
local act = wezterm.action

local config = {
	enable_wayland = false,

	-- force_reverse_video_cursor = true,
	default_cursor_style = "BlinkingUnderline",
	animation_fps = 60,
	font = wezterm.font_with_fallback({
		{ family = "Maple Mono NF", weight = "Regular" },
	}),
	font_size = 14,

	inactive_pane_hsb = {
		saturation = 0.55,
		brightness = 0.45,
	},

	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	window_decorations = "RESIZE",
	window_background_opacity = 0.9,

	window_padding = {
		top = "0.85cell",
		left = 23,
		right = 20,
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

-- Load modules
local colors = require("colors")
local ssh_cfg = require("ssh")

local function merge_configs(base_cfg, ...)
	for _, additional_config in ipairs({ ... }) do
		for k, v in pairs(additional_config) do
			base_cfg[k] = v
		end
	end
end

merge_configs(config, colors, ssh_cfg)

return config
