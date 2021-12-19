" Zak's vim conf file
"
"
" General Settings
"
"
set number
set mouse=a

" Keybindings
"
"
noremap <C-p> :GFiles <CR>
noremap <leader>f :Rg <CR>
noremap <C-l> :nohl <CR>

" Plugins
"
"
call plug#begin('~/.vim/plugged')

Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()
