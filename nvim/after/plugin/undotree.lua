local status, undotree = pcall(require, "undotree")
if (not status) then return end

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
