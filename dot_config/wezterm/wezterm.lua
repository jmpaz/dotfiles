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

	scrollback_lines = 10000,

	inactive_pane_hsb = {
		saturation = 0.55,
		brightness = 0.45,
	},

	use_fancy_tab_bar = false,
	window_decorations = "RESIZE",
	window_background_opacity = 0.9,

	window_padding = {
		left = 15,
		right = 15,
		top = 10,
		bottom = 0,
	},

	leader = { key = "a", mods = "ALT", timeout_milliseconds = 1000 },
	keys = {
		{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },

		{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

		{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },

		{ key = "s", mods = "LEADER", action = act.RotatePanes("Clockwise") },
		{ key = "s", mods = "LEADER|ALT", action = act.RotatePanes("CounterClockwise") },

		{ key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
		{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
		{
			key = "r",
			mods = "LEADER|ALT",
			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, pane, line)
					-- line will be `nil` if user hits escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "t", mods = "LEADER", action = act.ShowTabNavigator },
		{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

		{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{ key = "p", mods = "ALT", action = act.ActivateCommandPalette },

		-- Key tables
		{
			key = "r",
			mods = "LEADER",
			action = act.ActivateKeyTable({ name = "resize", one_shot = false, timeout_milliseconds = 2000 }),
		},
		{
			key = "m",
			mods = "LEADER",
			action = act.ActivateKeyTable({ name = "shift", one_shot = false, timeout_milliseconds = 2000 }),
		},
		{
			-- navigate prompt history (expects '❯')
			key = "~",
			mods = "ALT|SHIFT",
			action = wezterm.action.Search({
				Regex = [[^❯ .*(?:\n(?!❯ ).*)*]],
			}),
		},
	},

	key_tables = {
		resize = {
			{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
			{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
			{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
			{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
			{ key = "Escape", action = "PopKeyTable" },
			{ key = "Enter", action = "PopKeyTable" },
		},
		shift = {
			{ key = "h", action = act.MoveTabRelative(-1) },
			{ key = "j", action = act.MoveTabRelative(-1) },
			{ key = "k", action = act.MoveTabRelative(1) },
			{ key = "l", action = act.MoveTabRelative(1) },
			{ key = "Escape", action = "PopKeyTable" },
			{ key = "Enter", action = "PopKeyTable" },
		},
	},

	-- Status bar
	wezterm.on("update-right-status", function(window, pane)
		-- Workspace name
		local indicator = window:active_workspace()

		-- Leader/key table indicator
		if window:active_key_table() then
			indicator = window:active_key_table()
		end

		if window:leader_is_active() then
			indicator = wezterm.nerdfonts.md_apple_keyboard_command .. " "
		end

		-- Current directory
		local basename = function(s)
			-- Get the last segment of the path with regex
			return string.gsub(s, "(.*[/\\])(.*)", "%2")
		end

		local cwd = basename(pane:get_current_working_dir())

		-- Current process, timestamp
		local cmd = basename(pane:get_foreground_process_name())
		local time = wezterm.strftime("%H:%M")

		-- Set the status
		window:set_right_status(wezterm.format({
			{ Text = indicator },
			{ Text = " | " },
			{ Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
			{ Text = " | " },
			{ Foreground = { Color = "FFB86C" } },
			{ Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
			"ResetAttributes",
			{ Text = " | " },
			{ Text = wezterm.nerdfonts.md_clock .. "  " .. time },
			{ Text = " |" },
		}))
	end),

	unix_domains = {
		{
			name = "unix",
		},
	},
}

-- Merge ssh_config into main config
for k, v in pairs(ssh_config) do
	config[k] = v
end

return config
