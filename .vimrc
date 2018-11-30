let g:ale_completion_enabled = 1

call plug#begin('~/.vim/plugged')

Plug 'w0rp/ale'

Plug 'flowtype/vim-flow'

Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

Plug 'tpope/vim-fugitive'

Plug 'Shougo/denite.nvim'

Plug 'pangloss/vim-javascript'

Plug 'Shougo/deoplete.nvim'

Plug 'roxma/nvim-yarp'

Plug 'roxma/vim-hug-neovim-rpc'

" For func argument completion
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'

" For session management
Plug 'xolox/vim-session'
Plug 'xolox/vim-misc'

Plug 'vim-airline/vim-airline'

"" jsx syntax highlighting
Plug 'mxw/vim-jsx'

Plug 'tpope/vim-surround'


Plug 'flazz/vim-colorschemes'
Plug 'connorholyday/vim-snazzy'
Plug 'romainl/flattened'

Plug 'leafgarland/typescript-vim'

Plug 'digitaltoad/vim-pug'

Plug 'tpope/vim-vinegar'

Plug 'jnurmine/Zenburn'
call plug#end()

"" Run prettier before save
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue PrettierAsync

"" Show line numbers
set number

"" Save session
nnoremap <Leader>s :SaveSession<CR>

"" Restore session
nnoremap <Leader>r :OpenSession<CR>

"" Highlight search
set hlsearch

"" Incremental search
set incsearch

"" Clear highlight map
nnoremap <c-l> :nohl<CR>

"" Denite to ctrl + p
nnoremap <c-p> :Denite buffer file/rec <CR>

"" use ag for denite
call denite#custom#var('file/rec', 'command',
	\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

"" enable vim-javascript
let g:javascript_plugin_jsdoc = 1

"" start deoplete
let g:deoplete#enable_at_startup = 1

"" keybindings for moving up and down through denite selections
call denite#custom#map(
      \ 'insert',
      \ '<C-j>',
      \ '<denite:move_to_next_line>',
      \ 'noremap'
      \)
call denite#custom#map(
      \ 'insert',
      \ '<C-k>',
      \ '<denite:move_to_previous_line>',
      \ 'noremap'
      \)

"" Snippets
let g:neosnippet#enable_completed_snippet = 1

"" tabs
set tabstop=2
set shiftwidth=2
set expandtab

colorscheme Zenburn


"" Switching buffers
nnoremap <Leader>b :buffers<CR>:buffer<Space>

"" prevent deoplete from opening scratch
set completeopt-=preview

" denite content search
map <Leader>a :DeniteProjectDir -buffer-name=search-in-project -default-action=vsplitswitch grep:::!<CR>
 

call denite#custom#source(
 \ 'grep', 'matchers', ['matcher_regexp'])

" " use ag for content search
 call denite#custom#var('grep', 'command', ['ag'])
 call denite#custom#var('grep', 'default_opts',
     \ ['-i', '--vimgrep'])
 call denite#custom#var('grep', 'recursive_opts', [])
 call denite#custom#var('grep', 'pattern_opt', [])
 call denite#custom#var('grep', 'separator', ['--'])
 call denite#custom#var('grep', 'final_opts', [])

 "" search case sensitivity
 set smartcase

"" transparent background
hi Normal guibg=NONE ctermbg=NONE

set cursorline

let g:airline#extensions#ale#enabled = 1

let g:ale_linters = {
      \ 'javascript': ['eslint', 'flow']
      \}

let g:flow#showquickfix = 0

"" Load vimrc again
nnoremap <Leader>v :source ~/.vimrc<CR>
