let $FZF_DEFAULT_COMMAND = 'pt -l -g ""'
map <c-p> <esc>:FZF<cr>
vmap <c-p> <esc>:FZF expand("<cword>")<cr>
