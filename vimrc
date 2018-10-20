" Plugins {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'lifepillar/vim-solarized8'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'tommcdo/vim-fugitive-blame-ext'
Plug 't9md/vim-quickhl'
Plug 'fabiowguerra/vim-wmls-syntax'
Plug 'jreybert/vimagit'
Plug 'terryma/vim-multiple-cursors'
Plug 'gregsexton/gitv'
call plug#end()

" Custom highlighting with quickhl
let g:quickhl_manual_enable_at_startup=1
nmap <CR> <Plug>(quickhl-manual-this-whole-word)
vmap <CR> <Plug>(quickhl-manual-this-whole-word)
nmap <silent> <BS> <Plug>(quickhl-manual-reset):nohlsearch<CR>:set cursorline<CR>:redraw<CR>:sleep 150m<CR>:set nocursorline<CR>
augroup reset_cr_for_quickfix_and_cmdwin
    autocmd!
    autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
    autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
augroup END
" }}}

" Global settings {{{
set nocompatible
set number relativenumber

set hlsearch incsearch nowrapscan ignorecase smartcase
nohlsearch

set showcmd showmatch
set updatetime=100

set path+=**
set wildmenu wildignorecase complete+=d
set sidescroll=1 sidescrolloff=10
set showbreak="↪ " colorcolumn=+1

set laststatus=2 cmdheight=2
set confirm visualbell
set shortmess+=I

set noswapfile nobackup nowritebackup

set termguicolors
set background=dark
colorscheme solarized8

" Cursor shapes change depending on current mode
let s:pipeCursor = "\<Esc>[0 q"
let s:blockCursor = "\<Esc>[1 q"
let s:underlineCursor = "\<Esc>[3 q"
" Vim start in normal mode
let &t_ti = &t_ti.s:blockCursor
" Enter insert mode
let &t_SI = s:pipeCursor
" Enter replace mode
let &t_SR = s:underlineCursor
" Exit insert/replace mode, go back to normal mode
let &t_EI = s:blockCursor
" Exit Vim
let &t_te = s:pipeCursor.&t_te
unlet s:blockCursor
unlet s:pipeCursor
unlet s:underlineCursor
" }}}

" Shortcuts {{{
nnoremap <Leader>ev :vsplit $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>
inoremap jk <Esc>
map <Leader>y "+y

" File navigation
nnoremap <Leader>n :NERDTreeToggle<CR>
nnoremap <Leader>t :TagbarToggle<CR>

" Easy quickfix/location list navigation
" <Esc>j = <A-j> in my setup
nnoremap <Esc>j :lnext<CR>
nnoremap <Esc>k :lprevious<CR>
nnoremap <Esc>n :cnext<CR>
nnoremap <Esc>p :cprevious<CR>

nnoremap <Leader>l :lwindow<CR>
nnoremap <Leader>q :cwindow<CR>

" Save and quit shortcuts
nnoremap <C-s> :update<CR>
nnoremap ZA :xa<CR>
" }}}

" Cscope {{{
if has("cscope")
    set cscopeprg=cscope
    set cscopetagorder=0
    set cscopetag
    set nocscopeverbose
    set cscopequickfix=s-,c-,d-,i-,t-,e-,a-

    if filereadable("cscope.out")
        cscope add cscope.out
    endif

    set cscopeverbose
endif

" 0 or s: Find this C symbol
nnoremap <Leader>cs :lcscope find s <C-R>=expand("<cword>")<CR><CR>:lopen<CR>
" 1 or g: Find this definition
nnoremap <Leader>cg :lcscope find g <C-R>=expand("<cword>")<CR><CR>:lopen<CR>
" 2 or d: Find functions called by this function
nnoremap <Leader>cd :lcscope find d <C-R>=expand("<cword>")<CR><CR>:lopen<CR>
" 3 or c: Find functions calling this function
nnoremap <Leader>cc :lcscope find c <C-R>=expand("<cword>")<CR><CR>:lopen<CR>
" 4 or t: Find this text string
nnoremap <Leader>ct :lcscope find t <C-R>=expand("<cword>")<CR><CR>:lopen<CR>
" 6 or e: Find this egrep pattern
nnoremap <Leader>ce :lcscope find e <C-R>=expand("<cword>")<CR><CR>:lopen<CR>
" 7 or f: Find this file
nnoremap <Leader>cf :lcscope find f <C-R>=expand("<cfile>")<CR><CR>:lopen<CR>
" 8 or i: Find files #including this file
nnoremap <Leader>ci :lcscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>:lopen<CR>
" 9 or a: Find places where this symbol is assigned a value
nnoremap <Leader>ca :lcscope find a <C-R>=expand("<cword>")<CR><CR>:lopen<CR>
" }}}

" Configuration for C {{{
augroup Ccfg
    autocmd!
    autocmd FileType c setlocal listchars=trail:.,tab:>-,extends:>,precedes:< list
    autocmd FileType c setlocal tabstop=4 shiftwidth=4 shiftround expandtab
    autocmd FileType c setlocal textwidth=80 colorcolumn=+1
    autocmd FileType c setlocal tagcase=match
    autocmd FileType c setlocal cscopetag
    autocmd FileType c setlocal breakindent
    autocmd FileType c setlocal autoindent
    autocmd FileType c iabbrev <buffer> /*-*/ /*----------------------------------------------------------------------------*/
    autocmd FileType c call matchadd("ErrorMsg", '\v\s+$')
augroup END
" }}}

" Configuration for Vimscript"{{{
augroup Vimcfg
	autocmd!
	autocmd FileType vim setlocal tabstop=4 shiftwidth=4 shiftround expandtab
	autocmd FileType vim setlocal foldmethod=marker foldlevelstart=0 commentstring=\ \"\ %s 
augroup END
" }}}

" Utility functions {{{
function! s:AdjustFunctionDefinitions() " {{{
    let oldSearch = @/

    let preprocessorLine = '\s*#.*\n+'
    let ifPreprocessorLine = '^\s*#if.*\n+'
    let functionCommentLine = '\/\*\_[- ]+\*\/\n'
    let identifier = '\I\i*'
    let typeSymbols = '[ *\[\]\t]'
    let functionArguments = '\(\_[^)]+\)'
    let functionLikeConstructs = '%(if|for|while)'
    let @/ = '\v\n\zs\n*%('.functionCommentLine.')?\n*(%('.preprocessorLine.
        \ ')+%('.ifPreprocessorLine.')@<=)?\n*%('.functionCommentLine.
        \ ')?\n*(%('.identifier.'|'.typeSymbols.'){-})\_s+\ze'.identifier.
        \ functionLikeConstructs.'@<!\s*'.functionArguments.'\_s*\{'

    let separatorLines = '\r\r\r'
    let commentLine = '\/*-----------------------------------------------------'.
        \ '-----------------------*\/\r'
    let possiblePreprocessorLines = '\1'
    let functionReturnTypeLine = '\2\r'
    let substitutionPattern = separatorLines.possiblePreprocessorLines.
        \ commentLine.functionReturnTypeLine
    execute '%s//'.substitutionPattern.'/e'

    let @/ = oldSearch
endfunction " }}}

function! s:RunClangFormat() " {{{
    let style = "{".
        \ "BasedOnStyle: LLVM,".
        \ "UseTab: Never,".
        \ "IndentWidth: 4,".
        \ "BreakBeforeBraces: Allman,".
        \ "AllowShortIfStatementsOnASingleLine: false,".
        \ "IndentCaseLabels: false,".
        \ "ColumnLimit: 80,".
        \ "TabWidth: 4,".
        \ "AccessModifierOffset: -1,".
        \ "AllowAllParametersOfDeclarationOnNextLine: false,".
        \ "AllowShortFunctionsOnASingleLine: Empty,".
        \ "AlwaysBreakTemplateDeclarations: true,".
        \ "KeepEmptyLinesAtTheStartOfBlocks: false,".
        \ "AlwaysBreakAfterDefinitionReturnType: All,".
        \ "AlwaysBreakAfterReturnType: AllDefinitions,".
        \ "BinPackArguments: false,".
        \ "BinPackParameters: false,".
        \ "ContinuationIndentWidth: 4,".
        \ "Cpp11BracedListStyle: true,".
        \ "SortIncludes: false,".
        \ "NamespaceIndentation: None,".
        \ "MaxEmptyLinesToKeep: 1".
        \ "}"
    execute '%!clang-format -style="'.style.'" -assume-filename='.fnameescape('%')
endfunction " }}}

function! s:AdjustToPwCodingStandard() " {{{
    setlocal fileformat=unix fileencoding=utf-8 fixendofline
    call s:RunClangFormat()
    call s:AdjustFunctionDefinitions()
endfunction " }}}

function! PwAdjustToCodingStandard(...) " {{{
    if a:0 == 0
        let files = expand('%')
    else
        let files = join(map(copy(a:000), 'substitute(glob(v:val), "\n", " ", "ge")'))
    endif

    let oldMore = &more
    let oldBuffer = bufnr('%')
    set nomore

    execute 'args '.files
    noautocmd argdo silent call s:AdjustToPwCodingStandard() | update

    echom "Restoring settings and freeing used buffers..."
    execute 'buffer '.oldBuffer
    if a:0 != 0
        execute 'bdelete '.files
    endif
    echom "All done!"
    let &more = oldMore
endfunction " }}}

function! FindReleaseNotesVersionsForIssues(issues)
    let poswebIssues = a:issues
    "let issues = map(split(poswebIssues, '\v,\s+'), '"PRD90004-".v:val')
    let issues = split(poswebIssues)

    redir => issuesWithVersions
    for issue in issues
        echo issue
        execute 'g/\['.issue.'\]/?^POSWEB?p'
    endfor
    redir END

    echo issuesWithVersions
endfunction
" }}}
" Use plugin
" michaeljsmith/vim-indent-object
" jreybert/vimagit
" terryma/vim-multiple-cursors
" gregsexton/gitv
" Create custom wml syntax plugin
" Extend Fabio's custom wmls syntax plugin
" Create AZIP wrapper using /usr/share/vim/vim80/plugin/gzip.vim

