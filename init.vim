" Created By Jeremy Winterberg github.com/jeremydwayne

filetype plugin indent on

if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.config/nvim/plugged/')
  "CoC Conquer of Completion -- Intellisense
  " Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'nvim-lua/completion-nvim'

  " Sensible Default Vim Config
  Plug 'tpope/vim-sensible'
  Plug 'Shougo/vimproc.vim', {'do' : 'make'}
  Plug 'thinca/vim-quickrun'
  " Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  " ctrl+p :FZF

  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzy-native.nvim'

  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-fugitive'

  " tab autocomplete
  Plug 'ervandew/supertab'
  Plug 'alvan/vim-closetag'

  if has('nvim') || has('patch-8.0.902')
      Plug 'mhinz/vim-signify'
  else
      Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
  endif

  " Plug 'Townk/vim-autoclose'

  " Multiple Language Packs -- basically all of them
  Plug 'sheerun/vim-polyglot'

  " Auto end statement
  Plug 'tpope/vim-endwise'

  " Colored Parentheses
  Plug 'luochen1990/rainbow'

  " gcc commenting
  Plug 'tpope/vim-commentary'

  " Markdown Support
  Plug 'godlygeek/tabular'
  Plug 'vimwiki/vimwiki'

  " HTML shortcuts  ,y,
  Plug 'mattn/emmet-vim'

  " Most Recently Used files ,f
  " Plug 'vim-scripts/mru.vim'

  " <C-s>
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}

  Plug 'itchyny/lightline.vim'

  Plug 'mileszs/ack.vim'

  Plug 'tpope/vim-rails', { 'for': 'ruby' }

  Plug 'w0rp/ale'
  Plug 'sbdchd/neoformat'

  Plug 'Yggdroot/indentLine'

  Plug 'Shougo/deoppet.nvim', { 'do': ':UpdateRemotePlugins' }

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

  " Tags
  Plug 'ludovicchabant/vim-gutentags'

  " File Icons
  Plug 'ryanoasis/vim-devicons'

call plug#end()

let mapleader=" "


let g:sync_async_upload = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fast editing and reloading of vimrc configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <leader>e :e! ~/.config/nvim/init.vim<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Or if you have Neovim >= 0.1.5

packadd! dracula_pro

syntax enable

let g:dracula_italic = 1
let g:dracula_colorterm = 0
colorscheme dracula_pro


" write quit map
nmap <leader>wq :wq<cr>
nmap <leader>q :q!<cr>
nmap <leader>w :w<cr>

" Open and Close Location List (Error Messages)
nmap <leader>lc :lclose<cr>
nmap <leader>lo :lopen<cr>

" Highlights single column if you go past 80 columns for code legibility, this comment is an example
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%81v./



vnoremap <LeftRelease> "*ygv"

" Fix airline fonts from not displaying correctly
let g:airline_powerline_fonts = 1


" vim-markdown
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

"""""""""""""""""""""""""""""""
"" => MRU plugin
"""""""""""""""""""""""""""""""
"let MRU_Max_Entries = 400
"map <leader>f :MRU<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-multiple-cursors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:multi_cursor_next_key="\<C-s>"

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

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Remaps jk to ignore wrapped lines
nmap j gj
nmap k gk

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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General abbreviations
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")

""""""""""""""""""""""""""""""
" => Python section
""""""""""""""""""""""""""""""
" let python_highlight_all = 1
" au FileType python syn keyword pythonDecorator True None False self

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
" autocmd! BufWritePost,BufEnter * Neomake

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

let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1


" PHP CS FIXER
let g:php_cs_fixer_path = "~/tools/composer/vendor/bin/php-cs-fixer"
let g:php_cs_fixer_config_file = "~/.dotfiles/php_cs"
let g:php_cs_fixer_php_path = "php"               " Path to PHP
let g:php_cs_fixer_enable_default_mapping = 1     " Enable the mapping by default (<leader>pcd)
nnoremap <silent><leader>pcd :call PhpCsFixerFixDirectory()<CR>
nnoremap <silent><leader>pcf :call PhpCsFixerFixFile()<CR>

xmap <C-_> <Plug>Commentary
nmap <C-_> <Plug>Commentary
omap <C-_> <Plug>Commentary
nmap <C-_> <Plug>CommentaryLine

fun! TrimWhitespace()
	let l:save = winsaveview()
	keeppatterns %s/\s\+$//e
	call winrestview(l:save)
endfun

augroup jeremydwayne
	autocmd!
	autocmd BufWritePre * :call TrimWhitespace()
	autocmd BufWritePost *.php silent! call PhpCsFixerFixFile()
	autocmd FileType vim let b:coc_pairs_disabled = '"'
	" Conceal Level is dumb
	autocmd InsertEnter *.json setlocal conceallevel=0 concealcursor=
	autocmd InsertLeave *.json setlocal conceallevel=2 concealcursor=inc
	autocmd InsertEnter *.md setlocal conceallevel=0 concealcursor=
	autocmd InsertLeave *.md setlocal conceallevel=2 concealcursor=inc
	au BufNewFile,BufRead *.jinja set syntax=htmljinja
	au BufNewFile,BufRead *.mako set ft=mako

	au FileType gitcommit call setpos('.', [0, 1, 1, 0])

	autocmd! bufwritepost vimrc source ~/.vimrc
	" Markdown and VimWiki Filetypes
	autocmd BufRead,BufNewFile *.md setlocal spell
	au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

	autocmd BufRead,BufNewFile *.wiki setlocal spell
	au BufNewFile,BufFilePre,BufRead *.wiki set filetype=wiki
	" Close NerdTree when vim exits
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
	" Syntax Hilighting for ANTLR
	au BufRead,BufNewFile *.g set syntax=antlr3
	" New File Skeletons
	autocmd BufNewFile *
	\ let templatefile = expand("~/.dotfiles/templates/") . expand("%:e")|
	\ if filereadable(templatefile)|
	\   execute "silent! 0r " . templatefile|
	\   execute "normal Gdd/CURSOR\<CR>dw"|
	\ endif|
	au TabLeave * let g:lasttab = tabpagenr()
	" Return to last edit position when opening files (You want this!)
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

	" Neoformat / Prettier
	autocmd BufWritePre *.js Neoformat
	autocmd BufWritePre *.jsx Neoformat
	autocmd BufWritePre *.php Neoformat
	autocmd BufWritePre *.ruby Neoformat
	autocmd BufWritePre *.css Neoformat
	autocmd BufWritePre *.html Neoformat

	" Generate CTags for PHP
	au BufWritePost *.php silent! !eval '[ -f ".git/hooks/ctags" ] && .git/hooks/ctags' &
augroup END
