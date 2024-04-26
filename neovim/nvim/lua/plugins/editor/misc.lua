return {
	-- Encourages good habits
	{
		"m4xshen/hardtime.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
		},
		opts = {
			disabled_filetypes = {
				"checkhealth",
				"qf",
				"netrw",
				"NvimTree",
				"neo-tree",
				"neo-tree-popup",
				"lazy",
				"mason",
				"oil",
			},
		},
	},

	-- Provides scope guides and indent assistance
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		main = "ibl",
		opts = {},
	},

	-- Extra utilities for writing Obsidian markdown files
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			workspaces = {
				{
					name = "notes",
					path = "~/Documents/notes",
				},
			},
		},
	},

	-- Todo comment highlighting
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTelescope" },
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {},
	},
}
