local Keymaps = {}

-- @type LazyKeysLspSpec[] | nil
Keymaps._keys = nil

-- @alias LazyKeysLspSpec LazyKeysSpec | { has?: string}
-- @alias LazyKeysLsp LazyKeys | { has?: string }

-- @return LazyKeysLspSpec
function Keymaps.get()
	if Keymaps._keys then
		return Keymaps._keys
	end

	Keymaps._keys = {
		-- Diagnostics
		{ "<leader>df", vim.diagnostic.open_float, desc = "Open float" },
		{ "[d", vim.diagnostic.goto_prev, desc = "Go to previous" },
		{ "]d", vim.diagnostic.goto_next, desc = "Go to next" },

		-- LSP buffer
		{
			"gd",
			function()
				require("telescope.builtin").lsp_definitions({ reuse_win = true })
			end,
			desc = "Go to definition",
			has = "definition",
		},
		{ "gD", vim.lsp.buf.declaration, desc = "Go to declaration" },
		{
			"gi",
			function()
				require("telescope.builtin").lsp_implementations({ reuse_win = true })
			end,
			desc = "Go to implemenation",
		},
		{
			"gr",
			function()
				require("telescope.builtin").lsp_references({ reuse_win = true })
			end,
			desc = "References",
		},
		{
			"gt",
			function()
				require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
			end,
			desc = "Go to type definition",
		},
		{ "K", vim.lsp.buf.hover, desc = "Hover" },
		{ "<C-K>", vim.lsp.buf.signature_help, mode = { "i", "n" }, desc = "Signature help", has = "signatureHelp" },
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code actions", has = "codeAction", nowait = true },
		{ "<leader>rn", vim.lsp.buf.rename, desc = "Rename", nowait = true },
	}

	return Keymaps._keys
end

-- @param method string
function Keymaps.has(buffer, method)
	method = method:find("/") and method or "textDocument/" .. method
	local clients = vim.lsp.get_clients({ bufnr = buffer })

	for _, client in ipairs(clients) do
		if client.supports_method(method) then
			return true
		end
	end

	return false
end

function Keymaps.resolve(buffer)
	local keys = require("lazy.core.handler.keys")

	if not keys.resolve then
		return {}
	end

	local spec = Keymaps.get()
	local opts = Util.opts("nvim-lspconfig")
	local clients = vim.lsp.get_clients({ bufnr = buffer })

	for _, client in ipairs(clients) do
		local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
		vim.list_extend(spec, maps)
	end

	return keys.resolve(spec)
end

function Keymaps.on_attach(_, buffer)
	local Keys = require("lazy.core.handler.keys")
	local keymaps = Keymaps.resolve(buffer)

	for _, keys in pairs(keymaps) do
		if not keys.has or Keymaps.has(buffer, keys.has) then
			local opts = Keys.opts(keys)

			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = buffer

			vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
		end
	end
end

return Keymaps
