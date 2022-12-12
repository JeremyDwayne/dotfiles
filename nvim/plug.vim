" Automatically install vim-plug
 let data_dir = has('nvim') ? stdpath('data') . '/plugged' : '~/.vim'
 if empty(glob(data_dir . '/autoload/plug.vim'))
   silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
 endif

call plug#begin(data_dir . '/plugins')

" Utility
Plug 'lewis6991/impatient.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'
Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'
Plug 'numToStr/Comment.nvim'
Plug 'voldikss/vim-floaterm'
Plug 'danymat/neogen'
Plug 'max397574/better-escape.nvim'

" Telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'williamboman/mason.nvim'
Plug 'mfussenegger/nvim-lint'

" Git
Plug 'tpope/vim-fugitive'
Plug 'APZelos/blamer.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'rhysd/committia.vim'
Plug 'sindrets/diffview.nvim'

" Github
Plug 'pwntester/octo.nvim'

" Tpope
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'

" Appearance
Plug 'kyazdani42/nvim-tree.lua'
Plug 'p00f/nvim-ts-rainbow'
Plug 'Mofiqul/dracula.nvim'
Plug 'akinsho/bufferline.nvim'
Plug 'hoob3rt/lualine.nvim'
Plug 'folke/trouble.nvim'
Plug 'folke/lsp-colors.nvim'
Plug 'onsails/lspkind-nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'marko-cerovac/material.nvim'

" ThePrimeagen
Plug 'ThePrimeagen/harpoon'
Plug 'ThePrimeagen/git-worktree.nvim'
Plug 'ThePrimeagen/refactoring.nvim'

"Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/vscode-langservers-extracted'
Plug 'rafamadriz/friendly-snippets'
Plug 'ray-x/lsp_signature.nvim'

" Testing
Plug 'vim-test/vim-test'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-vim-test'
Plug 'olimorris/neotest-rspec'
Plug 'mfussenegger/nvim-dap'

" SQL
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-completion'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'norcalli/nvim-colorizer.lua'
Plug '$HOME/apps/psql'
Plug 'christoomey/vim-tmux-runner'
Plug 'm-novikov/tree-sitter-sql'
Plug 'nanotee/sqls.nvim'

" Open current file in web browser
Plug 'tyru/open-browser.vim'
Plug 'tyru/open-browser-github.vim'

call plug#end()
