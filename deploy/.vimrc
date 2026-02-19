" vim-plug plugin manager configuration
call plug#begin('~/.vim/plugged')

" vim-airline - status/tabline for vim
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" :GV
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

Plug 'zivyangll/git-blame.vim'

" Multiline
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

call plug#end()

" vim-airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" Display settings
set relativenumber

" git-blame.vim configuration
" Press <Leader>s (default is \s) to show git blame for current line
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>
