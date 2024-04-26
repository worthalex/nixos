-- List of special terminals
local terminals = {}

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{
				"<leader>tt",
				function()
					require("toggleterm").toggle(vim.v.count1)
				end,
				mode = "n",
				silent = true,
				desc = "Open terminal (cwd)",
			},
			{
				"<leader>tg",
				function()
					terminals.lazygit:toggle()
				end,
				mode = "n",
				silent = true,
				desc = "Open lazygit",
			},
			{ "<esc>", "<C-\\><C-n>", mode = "t", noremap = true, desc = "Enter normal mode" },
			{ "<C-h>", "<C-\\><C-n><C-W>h", mode = "t", noremap = true, desc = "Go to left window" },
			{ "<C-j>", "<C-\\><C-n><C-W>j", mode = "t", noremap = true, desc = "Go to lower window" },
			{ "<C-k>", "<C-\\><C-n><C-W>k", mode = "t", noremap = true, desc = "Go to upper window" },
			{ "<C-l>", "<C-\\><C-n><C-W>l", mode = "t", noremap = true, desc = "Go to right window" },
			{ "<C-t>", "<cmd>close<CR>", mode = "t", noremap = true, desc = "Close terminal" },
		},
		opts = {
			close_on_exit = true,
			direction = "float",
			float = {
				border = "curved",
			},
			hide_numbers = true,
			open_mapping = nil,
			shell = vim.o.shell,
			size = function()
				return vim.o.columns * 0.9
			end,
			start_in_insert = true,
		},
		config = function(_, opts)
			local Terminal = require("toggleterm.terminal").Terminal
			terminals["lazygit"] =
				Terminal:new(vim.tbl_deep_extend("keep", { cmd = "lazygit", hidden = true }, opts or {}))

			require("toggleterm").setup(opts)
		end,
	},
}
