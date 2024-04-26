local function extend_or_override(config, custom, ...)
	if type(custom) == "function" then
		config = custom(config, ...) or config
	elseif custom then
		config = vim.tbl_deep_extend("force", config, custom)
	end
	return config
end

return {
	-- Install java-test and java-debug-adapter
	{
		"mfussenegger/nvim-dap",
		optional = true,
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = function(_, opts)
					opts.ensure_installed = opts.ensure_installed or {}
					vim.list_extend(opts.ensure_installed, { "java-test", "java-debug-adapter" })
				end,
			},
		},
	},

	-- Configure nvim-lspconfig to install the server automatically via mason,
	-- but defer actually starting it to our configuration of nvim-jdtls below
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				jdtls = {},
			},
			setup = {
				jdtls = function()
					return true
				end,
			},
		},
	},

	-- Set up nvim-jdtls to attach to java files
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
		opts = function()
			return {
				root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,

				project_name = function(root_dir)
					return root_dir and vim.fs.basename(root_dir)
				end,

				jdtls_config_dir = function(project_name)
					return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
				end,

				jdtls_workspace_dir = function(project_name)
					return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
				end,

				cmd = { vim.fn.exepath("jdtls") },
				full_cmd = function(opts)
					local fname = vim.api.nvim_buf_get_name(0)
					local root_dir = opts.root_dir(fname)
					local project_name = opts.project_name(root_dir)
					local cmd = vim.deepcopy(opts.cmd)
					if project_name then
						vim.list_extend(cmd, {
							"-configuration",
							opts.jdtls_config_dir(project_name),
							"-data",
							opts.jdtls_workspace_dir(project_name),
						})
					end

					return cmd
				end,

				dap = {
					hotcodereplace = "auto",
					config_overrides = {},
				},
				dap_main = {},
				test = true,
			}
		end,
		config = function(_, opts)
			local mason_registry = require("mason-registry")
			local bundles = {} --@type string[]

			if opts.dap and mason_registry.is_installed("java-debug-adapter") then
				local java_debug_package = mason_registry.get_package("java-debug-adapter")
				local java_debug_path = java_debug_package:get_install_path()

				local jar_patterns = {
					java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
				}

				-- java-test depends on java-debug-adapter
				if opts.test and mason_registry.is_installed("java-test") then
					local java_test_package = mason_registry.get_package("java-test")
					local java_test_path = java_test_package:get_install_path()

					vim.list_extend(jar_patterns, {
						java_test_path .. "/extension/server/*.jar",
					})
				end

				for _, jar_pattern in ipairs(jar_patterns) do
					for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
						table.insert(bundles, bundle)
					end
				end
			end

			local function attach_jdtls()
				local fname = vim.api.nvim_buf_get_name(0)

				-- Configuration can be augmented and overridden by opts.jdtls
				local config = extend_or_override({
					cmd = opts.full_cmd(opts),
					root_dir = opts.root_dir(fname),
					init_options = {
						bundles = bundles,
					},

					-- Enable CMP capabilities
					capabilities = require("cmp_nvim_lsp").default_capabilities() or nil,
				}, opts.jdtls)

				require("jdtls").start_or_attach(config)
			end

			-- Attach jdtls for each buffer. This won't work the first time
			-- as this plugin loads depending on the file type.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "java" },
				callback = attach_jdtls,
			})

			-- Set up keymaps and DAP after the LSP is fully attached.
			-- This also takes care of enabling inlay hints.
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)

					if client and client.name == "jdtls" then
						-- jdtls supports inlay hints but doesn't appear to advertise it. This simply forces it on.
						local function debounce(ms, fn)
							local timer = vim.uv.new_timer()

							return function(...)
								local argv = { ... }

								timer:start(ms, 0, function()
									timer:stop()
									vim.schedule_wrap(fn)(unpack(argv))
								end)
							end
						end

						-- For some reason simply calling inlay_hint.enable doesn't work with jdtls
						-- so we wait one second before enabling it.
						debounce(1000, vim.lsp.inlay_hint.enable)(true, { bufnr = args.buf })

						local wk = require("which-key")

						wk.register({
							["<leader>cx"] = { name = "+extract" },
							["<leader>cxv"] = { require("jdtls").extract_variable_all, "Extract Variable" },
							["<leader>cxc"] = { require("jdtls").extract_constant, "Extract Constant" },
							["gs"] = { require("jdtls").super_implementation, "Goto Super" },
							["gS"] = { require("jdtls.tests").goto_subjects, "Goto Subjects" },
							["<leader>co"] = { require("jdtls").organize_imports, "Organise Imports" },
						}, { mode = "n", buffer = args.buf })

						wk.register({
							["<leader>c"] = { name = "+code" },
							["<leader>cx"] = { name = "+extract" },
							["<leader>cxm"] = {
								[[<ESC><CMD>lua require("jdtls").extract_method(true)<CR>]],
								"Extract Method",
							},
							["<leader>cxv"] = {
								[[<ESC><CMD>lua require("jdtls").extract_variable_all(true)<CR>]],
								"Extract Variable",
							},
							["<leader>cxc"] = {
								[[<ESC><CMD>lua require("jdtls").extract_constant(true)<CR>]],
								"Extract Constant",
							},
						}, { mode = "v", buffer = args.buf })

						if opts.dap and mason_registry.is_installed("java-debug-adapter") then
							-- Custom initialisation for Java debugger
							require("jdtls").setup_dap(opts.dap)
							require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)

							-- java-test requires java-debug-adapter to work
							if opts.test and mason_registry.is_installed("java-test") then
								-- Keymaps for Java test runner
								wk.register({
									["<leader>T"] = { name = "+test" },
									["<leader>Tt"] = { require("jdtls.dap").test_class, "Run All Tests" },
									["<leader>Tr"] = { require("jdtls.dap").test_nearest_method, "Run Nearest Test" },
									["<leader>TT"] = { require("jdtls.dap").pick_test, "Run Test" },
								}, { mode = "n", buffer = args.buf })
							end
						end
					end
				end,
			})

			-- autocmd won't fire the first time
			attach_jdtls()
		end,
	},
}
