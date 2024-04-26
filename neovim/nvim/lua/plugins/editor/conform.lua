return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPost", "BufNewFile" },
		-- Mason installs the formatters
		dependencies = "mason.nvim",
		opts = {
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				css = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				javascript = { { "prettierd", "prettier" } },
				just = { "just" },
				json = { "jq" },
				lua = { "stylua" },
				markdown = { "markdownlint" },
				nix = { "alejandra" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				toml = { "taplo" },
				typescript = { { "prettierd", "prettier" } },
				yaml = { "yq" },
			},
		},
	},
}
