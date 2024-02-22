return {
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters = {
				markdownlint = {
					args = { "--disable", "all" },
				},
			},
		},
	},
}
