return {
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>e",
				"<cmd>Oil<CR>",
				mode = "n",
				desc = "Open parent directory",
			},
		},
		opts = {},
		init = function()
			if vim.fn.argc(-1) == 1 then
				local stat = vim.uv.fs_stat(vim.fn.argv(0))
				if stat and stat.type == "directory" then
					require("oil")
				end
			end
		end,
	},
}
