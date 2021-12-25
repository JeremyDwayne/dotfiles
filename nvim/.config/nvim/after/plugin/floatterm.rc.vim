let g:floaterm_keymap_toggle = '<Leader>ft'
let g:floaterm_keymap_next   = '<Leader>fn'
let g:floaterm_keymap_prev   = '<Leader>fp'
let g:floaterm_keymap_new    = '<Leader>ff'

let g:floaterm_gitcommit='floaterm'
let g:floaterm_autoinsert=1
let g:floaterm_width=0.8
let g:floaterm_height=0.8
let g:floaterm_wintitle=0
let g:floaterm_autoclose=1

augroup FloatermCustomisations
    autocmd!
    autocmd ColorScheme * highlight FloatermBorder guibg=none
augroup END
