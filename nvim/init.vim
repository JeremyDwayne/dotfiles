autocmd!
scriptencoding utf-8
if !1 | finish | endif

let mapleader=","
set nocompatible
set number
syntax enable
set fileencodings=utf-8
set encoding=utf-8
set title
set autoindent
set nobackup
set hlsearch
set showcmd
set cmdheight=1
set laststatus=2
set scrolloff=10
set expandtab
set shell=zsh
set backupskip=/tmp/*,/private/tmp/*

if has('nvim')
	set inccommand=split
endif

set t_BE=

set nosc noru nosm
set lazyredraw

set ignorecase
set smarttab

filetype plugin indent on
set shiftwidth=2
set tabstop=2
set ai
set si
set nowrap
set backspace=start,eol,indent

set path+=**
set wildignore+=*/node_modules/*

autocmd InsertLeave * set nopaste

set formatoptions+=r

set cursorline
highlight Visual cterm=NONE ctermbg=236 ctermfg=NONE guibg=Grey40
highlight LineNr cterm=none ctermfg=240 guifg=#2b506e guibg=#000000

" File types
" JavaScript
au BufNewFile,BufRead *.es6 setf javascript
" TypeScript
au BufNewFile,BufRead *.tsx setf typescriptreact
" Markdown
au BufNewFile,BufRead *.md set filetype=markdown
" Flow
au BufNewFile,BufRead *.flow set filetype=javascript

set suffixesadd=.js,.es,.jsx,.json,.css,.less,.sass,.styl,.php,.py,.md

autocmd FileType coffee setlocal shiftwidth=2 tabstop=2
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2

" Imports
runtime ./plug.vim
if has("unix")
  let s:uname = system("uname -s")
  if s:uname == "Darwin\n"
    runtime ./macos.vim
  endif
endif

" Keybinds
runtime ./maps.vim

" Syntax & Theme
if exists("&termguicolors") && exists("&winblend")
  syntax enable
  set termguicolors
  set winblend=0
  set wildoptions=pum
  set pumblend=5
  set background=dark
  
  " packadd! dracula_pro
  " let g:dracula_colorterm=0
  " colorscheme dracula_pro
endif

set t_ZH=[3m
set t_ZR=[23m
colorscheme codedark
highlight Comment cterm=italic
