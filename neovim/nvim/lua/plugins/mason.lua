return {

	-- cmdline tools and lsp servers
	{

		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				-- C/C++
				"clang-format",

				-- JavaScript / TypeScript
				"prettier",
				"prettierd",

				-- JSON
				"jq",

				-- Lua
				"stylua",

				-- Markdown
				"markdownlint",

				-- sh
				"shellcheck",
				"shfmt",

				-- TOML
				"taplo",

				-- YAML
				"yq",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)

			local mason_registry = require("mason-registry")

			mason_registry:on("package:install:success", function()
				vim.defer_fn(function()
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)

			local function ensure_installed()
				if Util.is_nixos then
					-- Packages should be installed via Nix
					return
				end

				for _, tool in ipairs(opts.ensure_installed) do
					local package = mason_registry.get_package(tool)

					if not package:is_installed() then
						package:install()
					end
				end
			end

			if mason_registry.refresh then
				mason_registry.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
}
