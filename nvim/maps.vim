nmap <leader>ve :edit ~/.config/nvim/init.vim<cr>
nmap <leader>vr :source ~/.config/nvim/init.vim<cr>
nmap <leader>so :source %<cr>

nmap <leader>k :nohlsearch<CR>
nmap <leader>Q :bufdo bdelete<cr>
nn <leader>bd  :bd<cr>

" Allow gf to open non-existent files
map gf :edit <cfile><cr>

nnoremap <S-C-p> "0p

" Delete without yank
nnoremap <leader>d "_d
nnoremap x "_x

" Increment / Decrement
nnoremap + <C-a>
nnoremap - <C-x>

" Delete a word backwards
nnoremap dw vb"_d

" Select All
nmap <C-a> gg<S-v>G

" Save with root permission
command! W w !sudo tee > /dev/null %

" Search for selected text
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" nmap te :tabedit
" nmap <S-Tab> :tabprev<Return>
" nmap <Tab> :tabnext<Return>

nmap <leader>ss :split<Return><C-w>w
nmap <leader>sv :vsplit<Return><C-w>w
nmap <silent><leader>sq :q<cr>

map <leader>sh <C-w>h
map <leader>sk <C-w>k
map <leader>sj <C-w>j
map <leader>sl <C-w>l

" Fugitive
nmap <leader>gs :G<CR>
" Choose right merge
nmap <leader>gj :diffget //3<CR>
" Choose left merge
nmap <leader>gf :diffget //2<CR>
nnoremap <leader>gc :GCheckout<CR>
nnoremap <leader>gb :Git blame<CR>

let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'

" Move Lines
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" Maintain the cursor position when yanking a visual selection
" http://ddrscott.github.io/blog/2016/yank-without-jank/
vnoremap y myy`y
vnoremap Y myY`y

" When text is wrapped, move by terminal rows, not lines, unless a count is provided
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Paste replace visual selection without copying it
vnoremap <leader>p "_dP
" Make Y behave like the other capitals
nnoremap Y y$

" Keep search results centered
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" Quicky escape to normal mode
imap jk <esc>

" Easy insertion of a trailing ; or , from insert mode
imap ;; <Esc>A;<Esc>
imap ,, <Esc>A,<Esc>
nnoremap <leader>; A;<Esc>
nnoremap <leader>, A,<Esc>

" Formatting
" Format JSON with JQ
nnoremap <leader>jf :%!jq<CR>

" Telescope
nnoremap <silent> ;f <cmd>Telescope find_files<cr>
nnoremap <C-p> <cmd>Telescope git_files<cr>
nnoremap <silent> ;r <cmd>Telescope live_grep<cr>
nnoremap <silent> \\ <cmd>Telescope buffers<cr>
nnoremap <silent> ;; <cmd>Telescope help_tags<cr>
nnoremap <silent> ;d :lua search_dotfiles()<cr>
nnoremap <silent> // <cmd>Telescope current_buffer_fuzzy_find<cr>

" LSP config
nnoremap <silent> gD <Cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd <Cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K  <Cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <space>wa <cmd>lua vim.lsp.buf.add_workspace_folder()<CR>
nnoremap <silent> <space>wr <cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>
nnoremap <silent> <space>wl <cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>
nnoremap <silent> <space>D <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> <space>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <space>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> <space>e <cmd>lua vim.diagnostic.show_line_diagnostics()<CR>
nnoremap <silent> <C-j> <cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> <C-f> <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> <leader>q <cmd>lua vim.diagnostic.set_loclist()<CR>
nnoremap <silent> <leader>f <cmd>lua vim.lsp.buf.format({async = true})<CR>

" LSPSaga
nnoremap <silent> <C-j> <Cmd>Lspsaga diagnostic_jump_next<CR>
nnoremap <silent>K <Cmd>Lspsaga hover_doc<CR>
inoremap <silent> <C-k> <Cmd>Lspsaga signature_help<CR>
nnoremap <silent> gh <Cmd>Lspsaga lsp_finder<CR>

" Harpoon
" removing harpoon for now till I have time to figure out why its conflicting
" with the LSP
" nnoremap <silent> <C-m> :lua require("harpoon.mark").add_file()<CR>
" nnoremap <silent> <C-e> :lua require("harpoon.ui").toggle_quick_menu()<CR>
" nnoremap <silent> <C-h>1 :lua require("harpoon.ui").nav_file(1)<CR>
" nnoremap <silent> <C-h>2 :lua require("harpoon.ui").nav_file(2)<CR>
" nnoremap <silent> <C-h>3 :lua require("harpoon.ui").nav_file(3)<CR>
" nnoremap <silent> <C-h>4 :lua require("harpoon.ui").nav_file(4)<CR>
" nnoremap <silent> <C-g> :lua require("harpoon.mark").rm_file()<CR>
" nnoremap <silent> <leader><C-r> :lua require("harpoon.mark").shorten_list()<CR>
" nnoremap <silent> <leader><C-d> :lua require("harpoon.mark").clear_all()<CR>
" nnoremap <silent> <C-h>r :lua require("harpoon.mark").promote()<CR>
" nnoremap <silent> <leader>tu :lua require("harpoon.term").gotoTerminal(1)<CR>
" nnoremap <silent> <leader>te :lua require("harpoon.term").gotoTerminal(2)<CR>
" nnoremap <silent> <leader>cu :lua require("harpoon.term").sendCommand(1, 1)<CR>
" nnoremap <silent> <leader>ce :lua require("harpoon.term").sendCommand(1, 2)<CR>

" Floaterm
nnoremap <silent> <leader>ff :FloatermNew<CR>
tnoremap <silent> <leader>ff <C-\><C-n>:FloatermNew<CR>
nnoremap <silent> <leader>fp :FloatermPrev<CR>
tnoremap <silent> <leader>fp <C-\><C-n>:FloatermPrev<CR>
nnoremap <silent> <leader>fn :FloatermNext<CR>
tnoremap <silent> <leader>fn <C-\><C-n>:FloatermNext<CR>
nnoremap <silent> <leader>ft :FloatermToggle<CR>
tnoremap <silent> <leader>ft <C-\><C-n>:FloatermToggle<CR>
tnoremap <silent> <leader>fq <C-\><C-n>:FloatermKill<CR>

" These commands will navigate through buffers in order regardless of which mode you are using
" e.g. if you change the order of buffers :bnext and :bprevious will not respect the custom ordering
nnoremap <silent><Tab> :BufferLineCycleNext<CR>
nnoremap <silent><S-Tab> :BufferLineCyclePrev<CR>

" These commands will move the current buffer backwards or forwards in the bufferline
" nnoremap <silent><mymap> :BufferLineMoveNext<CR>
" nnoremap <silent><mymap> :BufferLineMovePrev<CR>

" These commands will sort buffers by directory, language, or a custom criteria
" nnoremap <silent>be :BufferLineSortByExtension<CR>
" nnoremap <silent>bd :BufferLineSortByDirectory<CR>
" nnoremap <silent><mymap> :lua require'bufferline'.sort_buffers_by(function (buf_a, buf_b) return buf_a.id < buf_b.id end)<CR>

" vim-test
nmap <leader>tn :TestNearest<CR>
nmap <leader>tf :TestFile<CR>
nmap <leader>ts :TestSuite<CR>
nmap <leader>tl :TestLast<CR>
nmap <leader>tv :TestVisit<CR>

" Trouble
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle lsp_document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>

" NETRW
" noremap <silent> <C-E> :call ToggleNetrw()<CR>

" Execute It!
nnoremap <leader>x :!chmod +x %<cr>
nnoremap <leader>F :silent !tmux neww tmux-sessionizer<cr>

nnoremap <leader>; :lua require("theprimeagen.git-worktree").execute(vim.loop.cwd(), "just-build")<CR>

" SQL
" nnoremap <buffer> <leader>X :terminal; ~/work/scripts/replica < '%'<cr>
nnoremap <leader>se :SqlsExecuteQueryVertical<cr>

" NVIM Tree
" See keybinds: https://github.com/kyazdani42/nvim-tree.lua#default-actions
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>
