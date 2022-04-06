autocmd!
scriptencoding utf-8
if !1 | finish | endif

let mapleader="\<space>"
syntax enable
set nocompatible
set number
set hidden
set fileencodings=utf-8
set encoding=utf-8
set title
set undofile
set autoindent
set hlsearch
set showcmd
set cmdheight=1
set laststatus=2
set signcolumn=yes:2
set expandtab
set shell=zsh
set ignorecase
set smartcase
set wildmode=longest:full,full
set t_BE=
set nosc noru nosm
set lazyredraw
set confirm
set exrc
set backup
set backupskip=/tmp/*,/private/tmp/*
set backupdir=~/.local/share/nvim/backup//
set updatetime=300 " Reduce time for highlighting other references
set redrawtime=10000 " Allow more time for loading syntax on large files
set ignorecase
set smarttab
set shiftwidth=2
set tabstop=2
set ai
set si
set nowrap
set backspace=start,eol,indent
set list
set listchars=tab:▸\ ,trail:·
set mouse=a
set scrolloff=8
set sidescrolloff=8
set nojoinspaces
set splitbelow
set splitright
set path+=**
set wildignore+=*/node_modules/*

filetype plugin indent on
if has('nvim')
	set inccommand=split
endif

autocmd InsertLeave * set nopaste

" Remember where you were in vim
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

set formatoptions+=r

set cursorline
highlight Visual cterm=NONE ctermbg=236 ctermfg=NONE guibg=Grey40
highlight LineNr cterm=none ctermfg=240 guifg=#2b506e guibg=#000000

" block in normal mode, a vertical bar in insert mode, and a underscore in replace mode.
let &t_EI = "\<Esc>[1 q"
let &t_SR = "\<Esc>[3 q"
let &t_SI = "\<Esc>[5 q"

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
  else
    runtime ./linux.vim
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
  
  lua require('colorbuddy').colorscheme('gruvbuddy')
  " packadd! dracula_pro
  " let g:dracula_colorterm=0
  " let g:dracula_use_term_italics=1
  " colorscheme dracula_pro
endif

set t_ZH=[3m
set t_ZR=[23m
highlight Comment cterm=italic

set completeopt=menu,menuone,noselect

" NETRW
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15
" let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'
" augroup ProjectDrawer
"   autocmd!
"   autocmd VimEnter * :Vexplore
" augroup END

let g:NetrwIsOpen=0

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i 
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore
    endif
endfunction

" Vim Tmux Runner
let g:VtrInitialCommand = "~/work/scripts/replica"
let g:VtrStripLeadingWhitespace = 1
let g:VtrClearEmptyLines = 1
let g:VtrOrientation = "h"
let g:VtrPercentage = 50
let g:VtrUseVtrMaps = 1
