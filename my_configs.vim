" set the runtime path to include Vundle and initialize
set rtp+=~/.vim_runtime/sources_non_forked/Vundle.vim
call vundle#begin('~/.vim_runtime/sources_non_forked')

    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'

    " Track the engine.
    Plugin 'SirVer/ultisnips'

    " Snippets are separated from the engine. Add this if you want them:
    Plugin 'honza/vim-snippets'

    " Auto Complete
    Plugin 'Valloric/YouCompleteMe'

    " Multiple Cursors for VIM Editing
    Plugin 'terryma/vim-multiple-cursors'

    " Vimple
    Plugin 'dahu/vimple'

    " Asif
    Plugin 'dahu/Asif'

    " Syntax Range
    Plugin 'vim-scripts/SyntaxRange'

    " Asciidoc
    Plugin 'dahu/vim-asciidoc'

    " All the color schemes
    Plugin 'flazz/vim-colorschemes'

call vundle#end()
" These are custom vimrc additions
" Sym Link this to ~./vim_runtime/ for the ultimate vimrc repo
" ln -s ~/dotfiles/my_configs.vim ~./vim_runtime/my_configs.vim

" CTags
set tags=./tags;

"colorscheme peaksea 
colorscheme dark-ruby 
set number

" Highlights if you go past 80 columns for code legibility, this comment is an example
" highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/

" Vim yank to clipboard
autocmd BufRead,BufNewFile *.md setlocal spell
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

" NERDTree Close on file open
let NERDTreeQuitOnOpen=1


" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]

" For tab completion YouCompleteMe
imap <Tab> <C-N>

" Syntax Hilighting for ANTLR
au BufRead,BufNewFile *.g set syntax=antlr3
