return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				changedelete = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				untracked = { text = "▎" },
			},
		},
	},
}
