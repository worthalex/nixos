return {
	{
		"famiu/bufdelete.nvim",
		cmd = { "Bdelete", "Bwipeout" },
		keys = {
			{
				"<leader>bd",
				function()
					require("bufdelete").bufdelete(0, false)
				end,
				desc = "Delete buffer",
			},
			{
				"<leader>bD",
				function()
					require("bufdelete").bufdelete(0, true)
				end,
				desc = "Delete buffer (force)",
			},
		},
	},
}
