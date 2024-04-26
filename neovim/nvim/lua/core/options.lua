local opts = {
	clipboard = "unnamedplus",

	-- set cmdheight to a reasonable default
	cmdheight = 1,

	-- conceallevel=2 results in a more pleasant conceal
	conceallevel = 2,

	-- mode is shown in lualine
	showmode = false,

	backup = false,
	completeopt = { "menuone", "noselect" },
	cursorline = true,
	expandtab = true,
	fileformats = { "unix", "dos" },
	hlsearch = true,
	ignorecase = true,
	laststatus = 3,
	mouse = "",
	number = true,
	numberwidth = 4,
	pumheight = 10,
	relativenumber = true,
	scrolloff = 9,
	shiftwidth = 4,
	showtabline = 2,
	sidescrolloff = 8,
	signcolumn = "yes",
	smartcase = true,
	smartindent = true,
	splitbelow = true,
	splitright = true,
	swapfile = false,
	tabstop = 4,
	termguicolors = true,
	timeoutlen = 1000,
	undofile = true,
	updatetime = 300,
	wrap = false,
	writebackup = false,
}

-- Shortcut for setting options
for name, value in pairs(opts) do
	vim.opt[name] = value
end
