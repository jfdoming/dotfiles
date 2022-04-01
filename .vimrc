" Thanks to https://devel.tech/snippets/n/vIIMz8vZ/load-vim-source-files-only-if-they-exist/
function! SourceIfExists(file)
    if filereadable(expand(a:file))
        exe 'source' a:file
    endif
endfunction

call SourceIfExists("~/.vimplugins")
call SourceIfExists("~/.vimaux")

syntax enable
:silent! colorscheme gruvbox
set background=dark

let g:gruvbox_improved_warnings = '1'
let g:gruvbox_underline = '1'

" Settings
set number
set relativenumber
set incsearch
set hlsearch
set backspace=indent,eol,start
set mouse=a
set ttymouse=sgr

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

" enable mouse scroll and select
set mouse=a

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
nnoremap <Left> :echo "This command is disabled."<CR>
nnoremap <Right> :echo "This command is disabled."<CR>
nnoremap <Up> :echo "This command is disabled."<CR>
nnoremap <Down> :echo "This command is disabled."<CR>

" Custom actions
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

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

" Ctrl-/ adds a C-style comment
nnoremap <silent> <C-\> <ESC>^i//<SPACE><ESC>j


" Prettier stuff

" Old method; nice, but broken. See https://github.com/prettier/vim-prettier/issues/214
""let g:prettier#autoformat = 0
""autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html Prettier

""let g:prettier#config#print_width = 80
""let g:prettier#config#tab_width = 2
""let g:prettier#config#use_tabs = 'false'
""let g:prettier#config#semi = 'true'
""let g:prettier#config#single_quote = 'false'
""let g:prettier#config#bracket_spacing = 'true'
""let g:prettier#config#jsx_bracket_same_line = 'false'
""let g:prettier#config#arrow_parens = 'avoid'
""let g:prettier#config#trailing_comma = 'none'
""let g:prettier#config#parser = 'babylon'
""let g:prettier#config#config_precedence = 'prefer-file'
""let g:prettier#config#prose_wrap = 'preserve'
""let g:prettier#config#html_whitespace_sensitivity = 'css'

" New method; hacky, but works!
autocmd BufNewFile,BufRead *.tsx,*.jsx setlocal filetype=typescript.tsx
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType typescript.tsx setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd BufWritePost * if count(["javascript"],&filetype) | call Prettier() | endif
autocmd BufWritePost * if count(["typescript"],&filetype) | call Prettier() | endif
autocmd BufWritePost * if count(["typescript.tsx"],&filetype) | call Prettier() | endif

function! Prettier()
    let l:view = winsaveview()
    :silent !npx prettier --write %
    :e
    :redraw!
    call winrestview(l:view)
    unlet l:view
endfunction

"" Fix typescript redraw timeout.
set re=0
