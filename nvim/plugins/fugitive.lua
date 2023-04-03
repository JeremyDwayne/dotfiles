return {
  'tpope/vim-fugitive',
  cmd = {"Git", "G"},
  keys = {
    { '<leader>gs', vim.cmd.Git, desc = 'Git Status' }
  }
}
