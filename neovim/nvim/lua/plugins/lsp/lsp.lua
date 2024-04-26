return {
	-- lspconfig
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		dependencies = {
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
			{ "folke/neodev.nvim", opts = {} },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		opts = {
			codelens = {
				enabled = true,
			},
			diagnostics = {
				float = {
					focusable = false,
					style = "minimal",
					border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
					source = "always",
					header = "",
					prefix = "",
					format = function(d)
						local t = vim.deepcopy(d)
						local code = d.code or (d.user_data and d.user_data.lsp.code)

						if code then
							t.message = string.format("%s [$s]", t.message, code):gsub("1. ", "")
						end

						return t.message
					end,
				},
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.HINT] = "",
						[vim.diagnostic.severity.INFO] = "",
					},
				},
				underline = true,
				update_in_insert = true,
				virtual_text = true,
			},
			servers = {
				cssls = {},
				eslint = {},
				html = {},
				jsonls = {
					on_new_config = function(new_config)
						new_config.settings.json.schemas = new_config.settings.json.schemas or {}
						vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
					end,
					settings = {
						json = {
							validate = {
								enable = true,
							},
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							workspace = {
								checkThirdParty = false,
							},
						},
					},
				},
				marksman = {},
				nil_ls = {},
				tsserver = {},
				yamlls = {
					on_new_config = function(new_config)
						new_config.settings.yaml.schemas = vim.tbl_deep_extend(
							"force",
							new_config.settings.yaml.schemas or {},
							require("schemastore").yaml.schemas()
						)
					end,
					settings = {
						redhat = { telemetry = { enabled = false } },
						yaml = {
							keyOrdering = false,
							schemaStore = {
								enable = false,
								url = "",
							},
							validate = true,
						},
					},
				},
			},
			setup = {},
		},
		config = function(_, opts)
			Util.lsp_on_attach(function(client, buffer)
				require("sopvim.lsp_keymaps").on_attach(client, buffer)
			end)

			local register_capability = vim.lsp.handlers["client/registerCapability"]

			vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
				local ret = register_capability(err, res, ctx)
				local client = vim.lsp.get_client_by_id(ctx.client_id)
				local buffer = vim.api.nvim_get_current_buf()

				require("sopvim.lsp_keymaps").on_attach(client, buffer)

				return ret
			end

			for severity, icon in pairs(opts.diagnostics.signs.text) do
				local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
				name = "DiagnosticSign" .. name

				vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			end

			Util.lsp_on_attach(function(client, buffer)
				if client.supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
				end
			end)

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
			})

			local servers = opts.servers
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				has_cmp and cmp_nvim_lsp.default_capabilities() or {},
				opts.capabilities or {}
			)

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			-- get all the servers that are available through mason-lspconfig
			local have_mason, mlsp = pcall(require, "mason-lspconfig")
			local all_mslp_servers = {}
			if have_mason then
				all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			end

			local ensure_installed = {} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
					if
						server_opts.mason == false
						or Util.is_nixos
						or not vim.tbl_contains(all_mslp_servers, server)
					then
						setup(server)
					elseif server_opts.enabled ~= false then
						ensure_installed[#ensure_installed + 1] = server
					end
				end
			end

			if have_mason then
				mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
			end
		end,
	},

	-- SchemaStore is lazy loaded when needed
	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false,
	},
}
