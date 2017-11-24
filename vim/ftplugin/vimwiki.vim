
augroup vimwiki
:silent au! BufRead ~/vimwiki/index.wiki !git pull
:silent au! BufWritePost ~/vimwiki/* !git add .;git commit -m "Auto commit + push.";git push
augroup END
