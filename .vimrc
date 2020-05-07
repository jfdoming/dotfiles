set nocompatible
filetype off " required for Vundle to work

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
syntax enable
colorscheme gruvbox
set background=dark

"let g:gruvbox_improved_warnings = '1'
"let g:gruvbox_underline = '1'


" Settings
set number
set relativenumber
set incsearch
set hlsearch
set backspace=indent,eol,start
set mouse=a

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
" Backspace on a tab removes 4 spaces
set softtabstop=4

" highlight the current line
set cursorline

" use a nicer pane border
set fillchars+=vert:│

" enable 80 char line
set cc=80

let g:syntastic_cpp_config_file='.syntastic_cpp_config'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Netrw settings
let g:netrw_browsex_viewer= "open"
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 20

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

" Thanks to https://github.com/curtischong for the fix!
xnoremap <expr> p 'pgv"'.v:register.'y'

" Custom actions

" Ctrl-P toggles the netrw drawer
let g:NetrwIsOpen=0

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore
    endif
endfunction

noremap <silent> <C-P> :call ToggleNetrw()<CR>
