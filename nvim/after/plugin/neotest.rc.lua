local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("neotest-rspec")({
      rspec_cmd = function()
            return vim.tbl_flatten({
              "bundle",
              "exec",
              "rspec",
            })
          end
    }),
    require("neotest-vim-test")({
      ignore_file_types = { "python", "vim", "lua" },
    }),
  },
})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>tf', ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", opts)
vim.keymap.set('n', '<leader>tn', ":lua require('neotest').run.run()<CR>", opts)
vim.keymap.set('n', '<leader>tnd', ":lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
vim.keymap.set('n', '<leader>st', ":lua require('neotest').run.stop()<CR>", opts)
vim.keymap.set('n', '<leader>ts', ":lua require('neotest').run.run(vim.fn.getcwd())<CR>", opts)
