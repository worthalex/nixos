Util = {}

if vim.uv.os_uname().version:find("NixOS") then
	Util.is_nixos = true
else
	Util.is_nixos = false
end

-- @param on_attach fun(client, buffer)
function Util.lsp_on_attach(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)

			on_attach(client, buffer)
		end,
	})
end

-- @param name string
-- @param fn fun(name: string)
function Util.on_load(name, fn)
	local config = require("lazy.core.config")

	if config.plugins[name] and config.plugins[name]._.loaded then
		fn(name)
	else
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyLoad",
			callback = function(event)
				if event.data == name then
					fn(name)
					return true
				end
			end,
		})
	end
end

-- @param name string
function Util.opts(name)
	local plugin = require("lazy.core.config").plugins[name]

	if not plugin then
		return {}
	end

	local Plugin = require("lazy.core.plugin")
	return Plugin.values(plugin, "opts", false)
end

function Util.value_or_none(condition, value)
	if condition then
		return value
	end
end
