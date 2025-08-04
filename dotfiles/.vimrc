" ---- vim-plug bootstrap ----------------------------------
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'tpope/vim-surround'
Plug 'gruvbox-community/gruvbox'

call plug#end()
" ----------------------------------------------------------

syntax on
set number relativenumber
set tabstop=4 shiftwidth=4 expandtab
set hidden
set mouse=a
set clipboard=unnamedplus
colorscheme gruvbox

" Quick toggle for NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
