local map = vim.keymap.set

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to a window using Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", silent = true })

-- Navigate buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer", silent = true })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })

-- Better indenting
map("v", "<", "<gv", { silent = true })
map("v", ">", ">gv", { silent = true })

-- Save file
map({ "i", "n", "s", "x" }, "<C-s>", "<cmd>:w<CR>", { desc = "Save file", silent = true })

map("n", "<leader>wd", "<C-w>q", { desc = "Close window", silent = true })
map("n", "<leader>wh", "<cmd>split<CR>", { desc = "Create horizontal split", silent = true })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Create vertical split", silent = true })
