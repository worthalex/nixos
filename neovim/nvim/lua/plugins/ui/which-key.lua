return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function(_, opts)
			local wk = require("which-key")

			wk.setup(opts)
			wk.register({
				["<leader>b"] = { name = "+buffer" },
				["<leader>ca"] = { name = "Code actions" },
				["<leader>d"] = { name = "+debug" },
				["<leader>f"] = { name = "+find" },
				["<leader>rn"] = { name = "Rename" },
			})
		end,
	},
}
