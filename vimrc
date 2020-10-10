" Created By Jeremy Winterberg (github.com/jeremydwayne 2017)
" A LOT of config pulled from the Ultimate VimRC (github.com/amix/vimrc)

filetype plugin indent on

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.vim/plugged/')
  " FTP Stuff
  Plug 'skywind3000/asyncrun.vim'
  Plug 'eshion/vim-sync'

  " Sensible Default Vim Config
  Plug 'tpope/vim-sensible'
  Plug 'Shougo/vimproc.vim', {'do' : 'make'}
  Plug 'thinca/vim-quickrun'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  " ctrl+p :FZF

  " vim colorscheme
  Plug 'dracula/vim', { 'as': 'dracula' }

  " tab autocomplete
  Plug 'ervandew/supertab'
  Plug 'alvan/vim-closetag'

  Plug 'airblade/vim-gitgutter'


  Plug 'Townk/vim-autoclose'

  " Auto end statements
  Plug 'tpope/vim-endwise'

  " gcc commenting
  Plug 'tpope/vim-commentary'

  " Markdown Support
  Plug 'godlygeek/tabular'
  Plug 'vimwiki/vimwiki'

  " HTML shortcuts  ,y,
  Plug 'mattn/emmet-vim'

  " Most Recently Used files ,f
  Plug 'vim-scripts/mru.vim'

  " <C-s>
  Plug 'terryma/vim-multiple-cursors'

  Plug 'itchyny/lightline.vim'

  Plug 'mileszs/ack.vim'
  Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle', 'NERDTree' ] }

  " Syntax
  Plug 'leafgarland/typescript-vim', { 'for': ['javascript', 'typescript'] }
  Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
  Plug 'tpope/vim-rails', { 'for': 'ruby' }


  Plug 'w0rp/ale'
  Plug 'sbdchd/neoformat'

  " Python
  Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
  " Plug 'heavenshell/vim-pydocstring', { 'for': 'python' }
  " Plug 'davidhalter/jedi-vim', { 'for': 'python' }

  " Typescript 
  Plug 'Quramy/tsuquyomi', {'for': 'typescript'}

  Plug 'Yggdroot/indentLine' 

  " Autonomous make integration (Compile)
  Plug 'neomake/neomake'

  Plug 'artur-shaik/vim-javacomplete2'
  Plug 'dansomething/vim-eclim' 

  if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
  endif
  " Plug 'Shougo/neosnippet'
  " Plug 'Shougo/neosnippet-snippets'

  " Javascript Plugins
  Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'typescript'] }
  Plug 'claco/jasmine.vim', { 'for': ['javascript', 'typescript'] }
  Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
  Plug 'mxw/vim-jsx', { 'for': 'javascript' }

  " PHP Plugins
  Plug 'StanAngeloff/php.vim'
  Plug 'stephpy/vim-php-cs-fixer'
  Plug 'ncm2/ncm2'
  Plug 'phpactor/phpactor'
  Plug 'phpactor/ncm2-phpactor'
  
call plug#end()

let mapleader=","

let g:sync_async_upload = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fast editing and reloading of vimrc configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>e :e! ~/.vimrc<cr>
autocmd! bufwritepost vimrc source ~/.vimrc

set timeoutlen=1000 ttimeoutlen=0

" CTags
set tags=./tags;

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
" For Neovim 0.1.3 and 0.1.4
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Or if you have Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif

" for vim 7
set t_Co=256

" for vim 8
if (has("termguicolors"))
  set termguicolors
endif

syntax enable

let g:dracula_italic = 1
colorscheme dracula
set background=dark

set noshowmode

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

set guifont=InputMono:h14
set hidden
set history=500

set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set autoindent
set fileformat=unix

set number
set mouse=a

set so=7
let $LANG='en'
set langmenu=en

"Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch 

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch 
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=1

" write quit map
nmap <leader>wq :wq<cr>
nmap <leader>q :q!<cr>
nmap <leader>w :w<cr>

" NO MORE FAILED FILE SAVES BECAUSE MY FINGERS ARE TOO FAT TO LET UP ON SHIFT
command W w
command WQ wq
command Wq wq
command Q q

" Open and Close Location List (Error Messages)
nmap <leader>lc :lclose<cr>
nmap <leader>lo :lopen<cr>

" Highlights single column if you go past 80 columns for code legibility, this comment is an example
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%81v./


" Markdown and VimWiki Filetypes
autocmd BufRead,BufNewFile *.md setlocal spell
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

autocmd BufRead,BufNewFile *.wiki setlocal spell
au BufNewFile,BufFilePre,BufRead *.wiki set filetype=wiki

" Vim yank to clipboard
set clipboard=unnamed

" Fix airline fonts from not displaying correctly
let g:airline_powerline_fonts = 1

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocmd VimEnter * NERDTree | wincmd p

let NERDTreeIgnore=['\~$', '.o$', 'bower_components', 'node_modules', '\.pyc$', '__pycache__']
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=0
let g:NERDTreeWinSize=35
nmap <leader>nn :NERDTreeToggle<cr>
nnoremap <silent> <leader>nb :NERDTreeFind<cr>

" Close NerdTree when vim exits
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('css', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('sass', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('ts', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('js', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('rb', 'Magenta', 'none', '#ff00ff', '#151515')



" Syntax Hilighting for ANTLR
au BufRead,BufNewFile *.g set syntax=antlr3

" New File Skeletons
autocmd BufNewFile *
\ let templatefile = expand("~/.dotfiles/templates/") . expand("%:e")|
\ if filereadable(templatefile)|
\   execute "silent! 0r " . templatefile|
\   execute "normal Gdd/CURSOR\<CR>dw"|
\ endif|

" vim-markdown
set nofoldenable
let g:vim_markdown_new_list_item_indent = 2
let g:markdown_fenced_languages = ['html', 'python', 'ruby', 'yaml', 'haml', 'bash=sh']

" vim-wiki
nmap <leader>whtml :VimwikiAll2HTML<cr>
nmap <leader>wit :VimwikiTable

let g:user_emmet_leader_key='<Tab>'
let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
let MRU_Max_Entries = 400
map <leader>f :MRU<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-multiple-cursors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:multi_cursor_next_key="\<C-s>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Git gutter (Git diff)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_enabled=0
let g:gitgutter_highlight_lines=1
nnoremap <silent> <leader>d :GitGutterToggle<cr>

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <c-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove 
map <leader>t<leader> :tabnext 


" Move lines of code around
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers 
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Remaps jk to ignore wrapped lines
nmap j gj
nmap k gk

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The Silver Searcher
" => Ag searching and cope displaying
"    requires ag.vim - it's much better than vimgrep/grep
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you Ag after the selected text
vnoremap <silent> gv :call VisualSelection('gv', '')<CR>

" Open Ag and put the cursor in the right position
map <leader>g :Ag 

" bind \ (backward slash) to grep shortcut
command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!

cnoreabbrev ag Ack
cnoreabbrev aG Ack
cnoreabbrev Ag Ack
cnoreabbrev AG Ack

nnoremap \ :Ag<SPACE>
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ackprg = 'ag --vimgrep --smart-case'
endif

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR><CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ag \"" . l:pattern . "\" " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

" Disable scrollbars (real hackers don't use scrollbars for navigation!)
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Turn persistent undo on 
"    means that you can undo even when you close a buffer/VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    set undodir=~/.vim_runtime/temp_dirs/undodir
    set undofile
catch
endtry

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General abbreviations
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")

""""""""""""""""""""""""""""""
" => Python section
""""""""""""""""""""""""""""""
" let python_highlight_all = 1
" au FileType python syn keyword pythonDecorator True None False self

au BufNewFile,BufRead *.jinja set syntax=htmljinja
au BufNewFile,BufRead *.mako set ft=mako


au FileType gitcommit call setpos('.', [0, 1, 1, 0])

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => lightline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
      \ 'colorscheme': 'darcula',
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             ['fugitive', 'readonly', 'filename', 'modified'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
      \ },
      \ 'separator': { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': ' ', 'right': ' ' }
      \ }

" vertical line indentation
let g:indentLine_color_term = 239
let g:indentLine_color_gui = '#09AA08'
let g:indentLine_char = '│'

" When reading a buffer (after 1s), and when writing.
" call neomake#configure#automake('rw', 1000)
autocmd! BufWritePost,BufEnter * Neomake

let g:deoplete#enable_at_startup = 1
let g:deoplete#omni_patterns = {}
let g:deoplete#omni_patterns.java = '[^. *\t]\.\w*'
"let g:deoplete#sources = {}
"let g:deoplete#sources._ = []
" let g:deoplete#file#enable_buffer_path = 1

let g:AutoClosePumvisible = {"ENTER": "<C-Y>", "ESC": "<ESC>"}

nnoremap <C-p> :<C-u>FZF<CR>

let g:syntastic_javascript_checkers = ['eslint']

" w0rp/ale
let g:ale_emit_conflict_warnings = 0
let g:ale_sign_error = '●' " Less aggressive than the default '>>'
let g:ale_sign_warning = '.'
let g:ale_lint_on_enter = 0 " Less distracting when opening a new file

" Neoformat / Prettier
autocmd BufWritePre *.js Neoformat
autocmd BufWritePre *.jsx Neoformat

let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

" Conceal Level is dumb
autocmd InsertEnter *.json setlocal conceallevel=0 concealcursor=
autocmd InsertLeave *.json setlocal conceallevel=2 concealcursor=inc
autocmd InsertEnter *.md setlocal conceallevel=0 concealcursor=
autocmd InsertLeave *.md setlocal conceallevel=2 concealcursor=inc

" javacomplete config
autocmd FileType java setlocal omnifunc=javacomplete#Complete
nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
imap <F4> <Plug>(JavaComplete-Imports-AddSmart)

nmap <F5> <Plug>(JavaComplete-Imports-Add)
imap <F5> <Plug>(JavaComplete-Imports-Add)

nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
imap <F6> <Plug>(JavaComplete-Imports-AddMissing)

nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
imap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)

" Run current file tests
map <leader>ju :JUnit %<cr>
" Run all tests
map <leader>ja :JUnit *<cr>

" Generate CTags for PHP
au BufWritePost *.php silent! !eval '[ -f ".git/hooks/ctags" ] && .git/hooks/ctags' &
