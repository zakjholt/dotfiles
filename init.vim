call plug#begin('~/.local/share/nvim/plugged')
  " Browser commands (-)
  Plug 'tpope/vim-vinegar'
  " File searching
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  " Elixir utilities
  Plug 'slashmili/alchemist.vim'
  " Surround commands (ysiw)
  Plug 'tpope/vim-surround'
  " Git integrations
  Plug 'tpope/vim-fugitive'
  " Bottom line for status
  Plug 'itchyny/lightline.vim'
  " Pack of language syntaxes
  Plug 'sheerun/vim-polyglot'
  " Linting engine
  Plug 'dense-analysis/ale'
  " Autocomplete popovers
  Plug 'Shougo/deoplete.nvim'
  " Python Autocompletion
  Plug 'deoplete-plugins/deoplete-jedi'
  " Distraction free mode
  Plug 'junegunn/goyo.vim'
call plug#end()

set number
set sts=2
set ts=2
set sw=2
set expandtab
set mouse=nv

" Format elixir files on save
autocmd BufWritePost *.exs,*.ex silent :!mix format %

" Format js and ts files on save
autocmd BufWritePost *.js,*.jsx,*.ts,*.tsx silent :!prettier --write %

" c-p file search
map <C-p> :Files <CR>

" find in files
map <Leader>f :Ag <CR>

" clear highlighting from search
map <C-l> :nohl <CR>

" open git status
map <Leader>g :Gstatus <CR>

" yank to system clipboard
vnoremap  <leader>y  "+y

" Colorscheme
syntax enable
set background=dark
let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'component_function': {
      \   'filename': 'LightlineFilename'
      \   }
      \ }

" Smart case for searching
set ignorecase
set smartcase
set incsearch


" Disable word wrapping
set nowrap

" Set Jenkinsfile files to groovy
au BufNewFile,BufRead Jenkinsfile setf groovy

" start deoplete
let g:deoplete#enable_at_startup = 1


" Goyo distraction free mode settings
let g:goyo_width=120
let g:goyo_height=100
map <Leader>z :Goyo <CR>

" Notes file
map <Leader>n :tabe ~/notes.md <CR>
