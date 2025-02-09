-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.wo.spell = false
    vim.wo.conceallevel = 0
  end,
})

-- fix conceallevel for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "md", "markdown", "mdx" },
  callback = function()
    vim.wo.conceallevel = 1
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "*/.env", "*/.env.*" },
  callback = function()
    vim.diagnostic.disable()
  end,
})
