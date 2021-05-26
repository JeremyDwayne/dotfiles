-- Set leader
vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- no hl
vim.api.nvim_set_keymap('n', '<Leader>h', ':set hlsearch!<CR>', {noremap = true, silent = true})

-- explorer
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', {noremap = true, silent = true})

-- telescope
vim.api.nvim_set_keymap('n', '<Leader>f', ':Telescope find_files<CR>', {noremap = true, silent = true})

-- dashboard
-- vim.api.nvim_set_keymap('n', '<Leader>;', ':Dashboard<CR>', {noremap = true, silent = true})


-- Comments
vim.api.nvim_set_keymap("n", "<Leader>/", ":CommentToggle<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("v", "<Leader>/", ":CommentToggle<CR>", {noremap = true, silent = true})

-- close buffer
vim.api.nvim_set_keymap("n", "<leader>w", ":BufferClose<CR>", {noremap = true, silent = true})

-- Open and Close QuickFix List
vim.api.nvim_set_keymap("n", '<C-q>', ':copen<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", '<C-c>', ':cclose<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", '<C-j>', ':cnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", '<C-k>', ':cprev<CR>', {noremap = true, silent = true})
-- Open and Close Location List
vim.api.nvim_set_keymap("n", '<leader>q', ':lopen<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", '<leader>c', ':lclose<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", '<leader>j', ':lnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", '<leader>k', ':lprev<CR>', {noremap = true, silent = true})

-- better window movement
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', {silent = true})
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', {silent = true})
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', {silent = true})
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', {silent = true})


vim.api.nvim_set_keymap('n', '<S-l>', '$', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-h>', '^', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<S-l>', '$', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<S-h>', '^', {noremap = true, silent = true})

vim.api.nvim_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", {noremap = true, silent = false})

-- TODO fix this
-- Terminal window navigation
vim.cmd([[
  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
  inoremap <C-h> <C-\><C-N><C-w>h
  inoremap <C-j> <C-\><C-N><C-w>j
  inoremap <C-k> <C-\><C-N><C-w>k
  inoremap <C-l> <C-\><C-N><C-w>l
  tnoremap <Esc> <C-\><C-n>
]])

-- Telescope Keybinds
vim.api.nvim_set_keymap('n', '<leader>ps',  [[<Cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input('Grep For > ')}) <CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pw',  [[<Cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.expand('<cword>')}) <CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>',       [[<Cmd>lua require('telescope.builtin').git_files()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>p',   [[<Cmd>lua require('telescope.builtin').find_files()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dot', [[<Cmd>lua require('lv-telescope').search_dotfiles()<CR>]], { noremap = true, silent = true })

-- TODO fix this
-- resize with arrows
vim.api.nvim_set_keymap('n', '<C-Up>', ':resize -2<CR>', {silent = true})
vim.api.nvim_set_keymap('n', '<C-Down>', ':resize +2<CR>', {silent = true})
vim.api.nvim_set_keymap('n', '<C-Left>', ':vertical resize -2<CR>', {silent = true})
vim.api.nvim_set_keymap('n', '<C-Right>', ':vertical resize +2<CR>', {silent = true})

-- better indenting
vim.api.nvim_set_keymap('v', '<', '<gv', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '>', '>gv', {noremap = true, silent = true})

-- I hate escape
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('i', 'kj', '<ESC>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('i', 'jj', '<ESC>', {noremap = true, silent = true})

-- Tab switch buffer
vim.api.nvim_set_keymap('n', '<TAB>', ':bnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-TAB>', ':bprevious<CR>', {noremap = true, silent = true})

-- Move selected line / block of text in visual mode
vim.api.nvim_set_keymap('x', 'K', ':move \'<-2<CR>gv-gv', {noremap = true, silent = true})
vim.api.nvim_set_keymap('x', 'J', ':move \'>+1<CR>gv-gv', {noremap = true, silent = true})

-- Better nav for omnicomplete
vim.cmd('inoremap <expr> <c-j> (\"\\<C-n>\")')
vim.cmd('inoremap <expr> <c-k> (\"\\<C-p>\")')
-- vim.cmd('inoremap <expr> <TAB> (\"\\<C-n>\")')
-- vim.cmd('inoremap <expr> <S-TAB> (\"\\<C-p>\")')

-- vim.api.nvim_set_keymap('i', '<C-TAB>', 'compe#complete()', {noremap = true, silent = true, expr = true})

-- vim.cmd([[
-- map p <Plug>(miniyank-autoput)
-- map P <Plug>(miniyank-autoPut)
-- map <leader>n <Plug>(miniyank-cycle)
-- map <leader>N <Plug>(miniyank-cycleback)
-- ]])

