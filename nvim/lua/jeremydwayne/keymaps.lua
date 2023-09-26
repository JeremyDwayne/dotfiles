local keymap = vim.keymap.set

keymap("n", ":W", vim.cmd.w)
keymap("n", ":Wq", vim.cmd.wq)
keymap("n", ":Q", vim.cmd.q)
keymap("n", "<leader>so", vim.cmd.so)
keymap("n", "<leader>pv", vim.cmd.Ex)
keymap("n", "<C-n>", vim.cmd.NvimTreeFindFileToggle)
keymap("n", "<leader>e", vim.cmd.NvimTreeFocus)

keymap("n", "<leader>bd", "<cmd>bd!<cr>")

-- option key movement on macos
keymap("n", "∆", ":m .+1<CR>==")
keymap("n", "˚", ":m .-2<CR>==")
keymap("i", "∆", "<Esc>:m .+1<CR>==gi")
keymap("i", "˚", "<Esc>:m .-2<CR>==gi")
keymap("v", "∆", ":m '>+1<CR>gv=gv")
keymap("v", "˚", ":m '<-2<CR>gv=gv")
-- alt key movement
keymap("n", "<A-j>", ":m .+1<CR>==")
keymap("n", "<A-k>", ":m .-2<CR>==")
keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv")
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv")

keymap("n", "J", "mzJ`z")
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- system yank and paste
keymap("x", "<leader>p", '"_dP')
keymap("n", "<leader>y", '"+y')
keymap("v", "<leader>y", '"+y')
keymap("n", "<leader>Y", '"+Y')

keymap("n", "<leader>d", '"_d')
keymap("v", "<leader>d", '"_d')

-- escape vertical edit mode gracefully
keymap("i", "<C-c>", "<Esc>")

keymap("n", "Q", "<nop>")

-- search for word cursor is on
keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- make current file executable (shell scripts)
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- bufferline tabs
keymap("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>")
keymap("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>")
keymap("n", "<leader>bn", "<cmd>BufferLineMoveNext<CR>")
keymap("n", "<leader>bp", "<cmd>BufferLineMovePrev<CR>")

keymap("n", "<leader>u", vim.cmd.UndotreeToggle)

-- nvim dap
keymap("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>")
keymap("n", "<leader>dus", function()
  local widgets = require('dap.ui.widgets');
  local sidebar = widgets.sidebar(widgets.scopes);
  sidebar.open();
end)
-- dap-go
keymap("n", "<leader>dgt", function()
  require("dap-go").debug_test()
end)
keymap("n", "<leader>dgl", function()
  require("dap-go").debug_last()
end)

-- gopher
keymap("n", "<leader>gsj", "<cmd> GoTagAdd json<CR>")
keymap("n", "<leader>ger", "<cmd> GoIfErr<CR>")
keymap("n", "<leader>gtg", "<cmd> GoTestsAll<CR>")

-- harpoon
keymap('n', '<leader>a', require('harpoon.mark').add_file)
keymap('n', '<C-e>', require('harpoon.ui').toggle_quick_menu)
keymap('n', '<leader>1', function() require('harpoon.ui').nav_file(1) end)
keymap('n', '<leader>2', function() require('harpoon.ui').nav_file(2) end)
keymap('n', '<leader>3', function() require('harpoon.ui').nav_file(3) end)
keymap('n', '<leader>4', function() require('harpoon.ui').nav_file(4) end)
