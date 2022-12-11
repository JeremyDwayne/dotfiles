let test#php#phpunit#executable = 'deliver vendor/bin/phpunit'

augroup AutoDeleteTestTermBuffers
    autocmd!
    autocmd BufLeave term://*artisan\stest* bdelete!
    autocmd BufLeave term://*phpunit* bdelete!
augroup END

let test#strategy = 'harpoon'
let g:test#harpoon_term = 2
