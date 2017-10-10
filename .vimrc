set term=xterm
set t_Co=256
let &t_AB="\e[48;5;%dm"
let &t_AF="\e[38;5;%dm"

set runtimepath^=~/.vim
filetype plugin on
set omnifunc=syntaxcomplete#Complete
set hlsearch
set incsearch
set smarttab
set wildmenu
set tabstop=2
set softtabstop=2
set expandtab
set number
set showcmd
set lazyredraw
set showmatch
set path+=**

call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go'
Plug 'w0ng/vim-hybrid'
Plug 'prettier/vim-prettier'
Plug 'pangloss/vim-javascript'
Plug 'Shougo/neocomplete'
call plug#end()

" Prettier
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql PrettierAsync
let g:prettier#config#semi = 'false'
let g:prettier#config#trailing_comma = 'none'
let g:prettier#config#parser = 'babylon'

" neocomplete
let g:neocomplete#enable_at_startup = 1
colorscheme hybrid
