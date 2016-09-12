" set the runtime path to include Vundle and initialize
set rtp+=~/.vim_runtime/sources_non_forked/Vundle.vim
call vundle#begin('~/.vim_runtime/sources_non_forked')

    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'

    "vim Colorscheme
    Plugin 'dracula/vim'
    " Plugin 'chriskempson/vim-tomorrow-theme'

    " tab autocomplete
    Plugin 'ervandew/supertab'

    Plugin 'airblade/vim-gitgutter'

    " Ruby Stuff
    Plugin 'tpope/vim-endwise'
    Plugin 'vim-ruby/vim-ruby'
    Plugin 'tpope/vim-rails'

call vundle#end()

" These are custom vimrc additions
" Sym Link this to ~./vim_runtime/ for the ultimate vimrc repo
" ln -s ~/dotfiles/my_configs.vim ~./vim_runtime/my_configs.vim

" CTags
set tags=./tags;

"colorscheme peaksea
" colorscheme Tomorrow-Night-Bright
colorscheme dracula
set guifont=Menlo\ for\ Powerline
let mapleader=","
set hidden
set history=100
filetype indent on
set nowrap
set shiftwidth=2
set tabstop=2
set expandtab
set smartindent
set autoindent
set number
set mouse=a


" NerdTree Stuff
" Close NerdTree and vim
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


" write quit map
nmap <leader>wq :wq<cr>
nmap <leader>lc :lclose<cr>
nmap <leader>lo :lopen<cr>
set term=screen-256color
set t_Co=256

" Vim-Rails Mappings
nmap <leader>ec :Econtroller %<cr>

" Highlights if you go past 80 columns for code legibility, this comment is an example
" highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/

" Vim yank to clipboard
autocmd BufRead,BufNewFile *.md setlocal spell

if $TMUX == ''
  set clipboard+=unnamed
endif
if has("unix")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    set clipboard=unamed
  else
    set clipboard=unnamedplus
  endif
endif

" Fixes airline fonts from not displaying correctly
let g:airline_powerline_fonts = 1

" Systastic python3 syntax support
let g:syntastic_python_python_exec = '/usr/bin/python3'
let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0

" NERDTree Close on file open
let NERDTreeQuitOnOpen=1

let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
let g:ycm_path_to_python_interpreter = '/usr/bin/python'
let g:ycm_server_use_vim_stdout = 0

" For tab completion YouCompleteMe
imap <Tab> <C-N>

" Syntax Hilighting for ANTLR
au BufRead,BufNewFile *.g set syntax=antlr3

" New File Skeletons
autocmd BufNewFile *
\ let templatefile = expand("~/dotfiles/templates/") . expand("%:e")|
\ if filereadable(templatefile)|
\   execute "silent! 0r " . templatefile|
\   execute "normal Gdd/CURSOR\<CR>dw"|
\ endif|
\ startinsert!
