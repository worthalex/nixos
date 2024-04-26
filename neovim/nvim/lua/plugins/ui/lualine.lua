return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	init = function()
		vim.g.lualine_laststatus = vim.o.laststatus

		vim.o.statusline = " "
	end,
	opts = function()
		-- PERF: we don't need lualine require
		local lualine_require = require("lualine_require")
		lualine_require.require = require

		return {
			options = {
				globalstatus = true,
				theme = "catppuccin",
			},
			sections = {
				lualine_b = {
					"branch",
					{
						"diff",
						source = function()
							local gitsigns = vim.b.gitsigns_status_dict

							if gitsigns then
								return {
									added = gitsigns.added,
									modified = gitsigns.changed,
									removed = gitsigns.removed,
								}
							end
						end,
					},
					"diagnostics",
				},
				lualine_x = {
					"encoding",
					{
						"fileformat",
						symbols = {
							dos = "CRLF",
							mac = "CR",
							unix = "LF",
						},
					},
					"filetype",
				},
			},
		}
	end,
}
