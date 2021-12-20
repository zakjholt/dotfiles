runtime ./plug.vim
runtime ./maps.vim
runtime ./lualine.vim

set number
set mouse=a
set termguicolors
set incsearch
set smartcase
set ignorecase
set tabstop=2
set shiftwidth=2
set expandtab
filetype plugin indent on
set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
command! -nargs=0 Format :call CocAction('format')



colorscheme NeoSolarized
