runtime! plugin/sensible.vim
set term=xterm
set t_Co=256
let &t_AB="\e[48;5;%dm"
let &t_AF="\e[38;5;%dm"

set runtimepath^=~/.vim
filetype plugin on
set omnifunc=syntaxcomplete#Complete
set hlsearch
set wildchar=<Tab> wildmode=full
set tabstop=2
set softtabstop=2
set expandtab
set number
set showcmd
set lazyredraw
set showmatch
set path+=**

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'fatih/vim-go'
Plug 'w0ng/vim-hybrid'
Plug 'prettier/vim-prettier'
Plug 'pangloss/vim-javascript'
Plug 'Raimondi/delimitMate'
Plug 'Shougo/neocomplete.vim'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'ternjs/tern_for_vim'
Plug 'leafgarland/typescript-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'luochen1990/rainbow'
call plug#end()

" Prettier
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql PrettierAsync
let g:prettier#config#semi = 'false'
let g:prettier#config#trailing_comma = 'none'
let g:prettier#config#parser = 'babylon'

" ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_custom_ignore = 'node_modules\*|*.swp|*.exe'

" neocomplete
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

" Clojure rainbow parens
let g:rainbow_active = 1

silent! colorscheme hybrid
