local wezterm = require("wezterm")

return {
	color_scheme = "Catppuccin Mocha",

	default_cursor_style = "BlinkingBar",
	animation_fps = 60,
	font = wezterm.font("Geist Mono"),
	font_size = 15.2,

	enable_tab_bar = false,
	window_background_opacity = 0.9,

	window_padding = {
		left = 15,
		right = 15,
		top = 10,
		bottom = 0,
	},
}
