" These are custom vimrc additions
" Sym Link this to ~./vim_runtime/ for the ultimate vimrc repo
" ln -s ~/dotfiles/my_configs.vim ~./vim_runtime/my_configs.vim

colorscheme peaksea
set number

" Highlights if you go past 80 columns for code legibility, this comment is an example
" highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/

" Vim yank to clipboard
set clipboard=unnamedplus

" Systastic python3 syntax support
let g:syntastic_python_python_exec = '/usr/bin/python3'

" NERDTree Close on file open
let NERDTreeQuitOnOpen=1
