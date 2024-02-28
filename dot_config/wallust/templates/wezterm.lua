local colors = {
	colors = {
		ansi = {
			"{{color0}}",
			"{{color1}}",
			"{{color2}}",
			"{{color3}}",
			"{{color4}}",
			"{{color5}}",
			"{{color6}}",
			"{{color7}}",
		},
		brights = {
			"{{color8}}",
			"{{color9}}",
			"{{color10}}",
			"{{color11}}",
			"{{color12}}",
			"{{color13}}",
			"{{color14}}",
			"{{color15}}",
		},

		background = "{{background}}",
		foreground = "{{foreground}}",

		cursor_fg = "{{color8}}",
		cursor_bg = "{{cursor}}",
		cursor_border = "{{cursor}}",
		compose_cursor = "{{color11}}",

		selection_fg = "{{foreground}}",
		selection_bg = "{{color8}}",

		scrollbar_thumb = "{{color8}}",
		visual_bell = "{{color0}}",
		split = "{{color15}}",
	},
}

return colors
