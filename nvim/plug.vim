" Automatically install vim-plug
 let data_dir = has('nvim') ? stdpath('data') . '/plugged' : '~/.vim'
 if empty(glob(data_dir . '/autoload/plug.vim'))
   silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
 endif

call plug#begin(data_dir . '/plugins')

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'p00f/nvim-ts-rainbow'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'
Plug 'tjdevries/colorbuddy.vim'
Plug 'tjdevries/gruvbuddy.nvim'

Plug 'akinsho/bufferline.nvim'
Plug 'hoob3rt/lualine.nvim'
Plug 'kristijanhusak/defx-git'
Plug 'kristijanhusak/defx-icons'
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'neovim/nvim-lspconfig'
Plug 'tami5/lspsaga.nvim'
" Outdated non-functioning
" Plug 'glepnir/lspsaga.nvim'
Plug 'folke/trouble.nvim'
Plug 'folke/lsp-colors.nvim'
Plug 'onsails/lspkind-nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'ThePrimeagen/harpoon'

"Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'rafamadriz/friendly-snippets'

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'numToStr/Comment.nvim'
"Not currently invited to copilot, don't load it
"Plug 'github/copilot.vim'

Plug 'voldikss/vim-floaterm'
Plug 'kana/vim-textobj-user' | Plug 'whatyouhide/vim-textobj-xmlattr'
Plug 'tpope/vim-projectionist'
Plug 'vim-test/vim-test'

Plug 'lewis6991/gitsigns.nvim'
Plug 'norcalli/nvim-colorizer.lua'


call plug#end()
