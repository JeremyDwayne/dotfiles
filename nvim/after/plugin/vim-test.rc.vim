let test#php#phpunit#executable = 'deliver vendor/bin/phpunit'

augroup AutoDeleteTestTermBuffers
    autocmd!
    autocmd BufLeave term://*artisan\stest* bdelete!
    autocmd BufLeave term://*phpunit* bdelete!
augroup END

let test#strategy = 'neovim'
let g:test#neovim#start_normal = 1
let test#neovim#term_position = "vert"

if has('nvim')
  tmap <C-o> <C-\><C-n>
endif
