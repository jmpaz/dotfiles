return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "rose-pine",
		},
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			-- Here's a quick fix for this warning:
			--
			--  WARN Highlight group 'Normal' has no background highlight
			-- Please provide an RGB hex value or highlight group with a background value for 'background_colour' option.
			-- This is the colour that will be used for 100% transparency.
			require("notify").setup({ background_colour = "#000000" })

			vim.notify = require("notify")
		end,
	},
}
