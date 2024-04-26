return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			events = { "BufReadPost", "BufWritePost", "InsertLeave" },
			linters = {
				cppcheck = {
					args = {
						"--enable=warning,style,performance,information,portability",
						"--template=gcc",
						function()
							if vim.bo.filetype == "cpp" then
								return "--language=c++"
							else
								return "--language=c"
							end
						end,
						"--inline-suppr",
						"--suppress=missingIncludeSystem",
						"--quiet",
						function()
							if vim.fn.isdirectory("build") == 1 then
								return "--cppcheck-build-dir=build"
							else
								return ""
							end
						end,
						"--template={file}:{line}:{column}: [{id}] {severity}: {message}",
					},
				},
			},
			linters_by_ft = {
				c = { "cppcheck" },
				cpp = { "cppcheck" },
				markdown = { "markdownlint" },
				nix = { "deadnix", "statix" },
				sh = { "shellcheck" },
			},
		},
		config = function(_, opts)
			local Lint = {}

			local lint = require("lint")

			for name, linter in pairs(opts.linters) do
				if type(linter) == "table" and type(lint.linters[name]) == "table" then
					lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
				else
					lint.linters[name] = linter
				end
			end

			lint.linters_by_ft = opts.linters_by_ft

			function Lint.debounce(ms, fn)
				local timer = vim.uv.new_timer()

				return function(...)
					local argv = { ... }

					timer:start(ms, 0, function()
						timer:stop()
						vim.schedule_wrap(fn)(unpack(argv))
					end)
				end
			end

			vim.api.nvim_create_autocmd(opts.events, {
				group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
				callback = function()
					Lint.debounce(100, require("lint").try_lint)()
				end,
			})
		end,
	},
}
