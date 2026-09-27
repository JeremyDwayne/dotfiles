-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

-- dw deletes the whole word under the cursor
keymap.set("n", "dw", "diw")

-- Secret Tunnel
keymap.set("n", "<leader>ct", ":CloakToggle<CR>")
