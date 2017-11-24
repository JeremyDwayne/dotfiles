
augroup vimwiki
au! BufRead ~/vimwiki/index.wiki !git pull
au! BufWritePost ~/vimwiki/* :silent !git add .;git commit -m "Auto commit + push.";git push
augroup END
