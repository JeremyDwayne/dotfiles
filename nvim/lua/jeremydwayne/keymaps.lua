vim.keymap.set("n", ":W", vim.cmd.w)
vim.keymap.set("n", ":Wq", vim.cmd.wq)
vim.keymap.set("n", ":Q", vim.cmd.q)
vim.keymap.set("n", "<leader>so", vim.cmd.so)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<C-n>", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeFocus)

vim.keymap.set("n", "<leader>bd", "<cmd>bd!<cr>")

-- option key movement on macos
vim.keymap.set("n", "∆", ":m .+1<CR>==")
vim.keymap.set("n", "˚", ":m .-2<CR>==")
vim.keymap.set("i", "∆", "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", "˚", "<Esc>:m .-2<CR>==gi")
vim.keymap.set("v", "∆", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "˚", ":m '<-2<CR>gv=gv")
-- alt key movement
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- system yank and paste
vim.keymap.set("x", "<leader>p", '"_dP')
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- escape vertical edit mode gracefully
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")

-- TODO: figure out what these do
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- search for word cursor is on
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- make current file executable (shell scripts)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- bufferline tabs
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineMoveNext<CR>")
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineMovePrev<CR>")

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
