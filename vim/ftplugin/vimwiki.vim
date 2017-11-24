
augroup vimwiki
au! BufRead ~/vimwiki/index.wiki !git pull
au! BufRead ~/vimwiki/diary/diary.wiki !git pull
au! BufWritePost ~/vimwiki/* !git add .;git commit -m "Auto commit + push.";git push
augroup END
