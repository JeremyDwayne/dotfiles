-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- local discipline = require("jeremydwayne.discipline")
-- discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Increment/Decrement
keymap.set("n", "+", "<C-a")
keymap.set("n", "-", "<C-x")

-- delete word backwards
keymap.set("n", "dw", "vb_d")

-- select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New Tab
keymap.set("n", "te", ":tabedit<Return>", opts)
-- keymap.set("n", "<tab>", ":tabnext<Return>", opts)
-- keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- keymap.set("n", "<leader>bd", ":bd<Return>", opts)

-- Split window
keymap.set("n", "<leader>ss", ":split<Return>", opts)
keymap.set("n", "<leader>sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "<leader>sh", "<C-w>h")
keymap.set("n", "<leader>sk", "<C-w>k")
keymap.set("n", "<leader>sj", "<C-w>j")
keymap.set("n", "<leader>sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end, opts)
keymap.set("n", "<C-f>", function()
  vim.diagnostic.goto_prev()
end, opts)

keymap.set("n", ":W", vim.cmd.w)
keymap.set("n", ":Wq", vim.cmd.wq)
keymap.set("n", ":Q", vim.cmd.q)
keymap.set("n", "<leader>so", vim.cmd.so)
keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- option key movement on macos
keymap.set("n", "∆", ":m .+1<CR>==")
keymap.set("n", "˚", ":m .-2<CR>==")
keymap.set("i", "∆", "<Esc>:m .+1<CR>==gi")
keymap.set("i", "˚", "<Esc>:m .-2<CR>==gi")
keymap.set("v", "∆", ":m '>+1<CR>gv=gv")
keymap.set("v", "˚", ":m '<-2<CR>gv=gv")
-- alt key movement
keymap.set("n", "<A-j>", ":m .+1<CR>==")
keymap.set("n", "<A-k>", ":m .-2<CR>==")
keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

keymap.set("n", "J", "mzJ`z")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- system yank and paste
keymap.set("x", "<leader>p", '"_dP')
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')

keymap.set("n", "<leader>d", '"_d')
keymap.set("v", "<leader>d", '"_d')

-- escape vertical edit mode gracefully
keymap.set("i", "<C-c>", "<Esc>")

keymap.set("n", "Q", "<nop>")

-- search for word cursor is on
keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- make current file executable (shell scripts)
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- bufferline tabs
keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>")
keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>")
keymap.set("n", "<leader>bn", "<cmd>BufferLineMoveNext<CR>")
keymap.set("n", "<leader>bp", "<cmd>BufferLineMovePrev<CR>")

keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

keymap.set("n", "<C-n>", "<cmd>Neotree toggle reveal<CR>")

-- nvim dap
keymap.set("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>")
keymap.set("n", "<leader>dus", function()
  local widgets = require("dap.ui.widgets")
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end)
-- dap-go
keymap.set("n", "<leader>dgt", function()
  require("dap-go").debug_test()
end)
keymap.set("n", "<leader>dgl", function()
  require("dap-go").debug_last()
end)

-- gopher
keymap.set("n", "<leader>gsj", "<cmd> GoTagAdd json<CR>")
keymap.set("n", "<leader>ger", "<cmd> GoIfErr<CR>")
keymap.set("n", "<leader>gtg", "<cmd> GoTestsAll<CR>")

keymap.set("n", "<leader>rn", ":IncRename ")

-- Refactoring
keymap.set("x", "<leader>re", function()
  require("refactoring").refactor("Extract Function")
end)
keymap.set("x", "<leader>rf", function()
  require("refactoring").refactor("Extract Function To File")
end)
-- Extract function supports only visual mode
keymap.set("x", "<leader>rv", function()
  require("refactoring").refactor("Extract Variable")
end)
-- Extract variable supports only visual mode
keymap.set("n", "<leader>rI", function()
  require("refactoring").refactor("Inline Function")
end)
-- Inline func supports only normal
keymap.set({ "n", "x" }, "<leader>ri", function()
  require("refactoring").refactor("Inline Variable")
end)
-- Inline var supports both normal and visual mode

keymap.set("n", "<leader>rb", function()
  require("refactoring").refactor("Extract Block")
end)
keymap.set("n", "<leader>rbf", function()
  require("refactoring").refactor("Extract Block To File")
end)
-- Extract block supports only normal mode
