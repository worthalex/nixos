return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			default_integrations = true,
			flavour = "mocha",
			integrations = {
				mason = true,
				neotree = true,
				which_key = true,
			},
			no_italic = true,
		},
		init = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
