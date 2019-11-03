set nocompatible
filetype off
syntax on
set backspace=indent,eol,start
set background=dark

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'chemzqm/vim-jsx-improve'
Plugin 'morhetz/gruvbox'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-syntastic/syntastic'

call vundle#end()
filetype plugin indent on
colorscheme gruvbox

"let g:gruvbox_improved_warnings = '1'
"let g:gruvbox_underline = '1'


" Settings
set number
set incsearch
set hlsearch

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Enable 80 char line
set cc=80

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Keybinds
noremap <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <ESC>:update<CR>
inoremap <silent> <C-S> <ESC>:update<CR>l

nnoremap <TAB> >>
nnoremap <S-TAB> <<

nnoremap j gj
nnoremap <Down> gj
nnoremap gj j
nnoremap g<Down> j
nnoremap k gk
nnoremap <Up> gk
nnoremap gk k
nnoremap g<Up> k

inoremap <c-z> <c-o>:u<CR>
