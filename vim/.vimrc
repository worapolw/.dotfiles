let mapleader = " "
let maplocalleader = " "
let clipboard = "unnamedplus"
filetype plugin indent on
set tabstop=4
set shiftwidth=4 
set expandtab 
set hls
set number
set relativenumber
set encoding=utf-8
map <C-[> <Esc>
noremap <Esc> :noh<CR>
map J <Nop>
map K <Nop>
map <C-w><C-v> <C-w><C-v><C-w><C-l>
map <C-w><C-s> <C-w><C-s><C-w><C-j>

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'vim-airline/vim-airline'
Plug 'haishanh/night-owl.vim'
Plug 'vim-airline/vim-airline-themes' 
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'mbbill/undotree'
Plug 'vimoxide/vim-cinnabar'
call plug#end()


if (has("termguicolors"))
 set termguicolors
endif
syntax enable

colorscheme cinnabar

" Transparent background — fall back to the terminal's background color
augroup TransparentBackground
  autocmd!
  autocmd ColorScheme * highlight Normal      ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight NonText     ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight LineNr      ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight SignColumn  ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
augroup END
highlight Normal      ctermbg=NONE guibg=NONE
highlight NonText     ctermbg=NONE guibg=NONE
highlight LineNr      ctermbg=NONE guibg=NONE
highlight SignColumn  ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE
