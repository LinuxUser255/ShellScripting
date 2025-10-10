"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"        ___       ______
"       /   |     / ____/_  ______
"      / /| |    / /_  / / / / __ \
"     / ___ |   / __/ / /_/ / / / /
"    /_/  |_|  /_/    \__,_/_/ /_/
"     _    ___           ____
"    | |  / (_)___ ___  / __ \_____
"    | | / / / __ `__ \/ /_/ / ___/
"    | |/ / / / / / / / _, _/ /__
"    |___/_/_/ /_/ /_/_/ |_|\___/
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Enable syntax highlighting
syntax on

" General settings
set noerrorbells
set tabstop=4 softtabstop=4
set expandtab
set smartindent
set nu
set relativenumber
set ignorecase
set nowrap
set noshowmode
set termguicolors
set undofile
set undodir=~/.vim/undodir
set incsearch
set nohlsearch
set shiftwidth=4
set noswapfile
set nobackup
set scrolloff=8
set signcolumn=yes
set isfname+=@-@
set updatetime=50
set guicursor=
" Highlight current line
set cursorline
" Display vertical line at column 80
set colorcolumn=80

" Set <Space> as leader key
let mapleader = " "
nnoremap <Space> <Nop>
" Map <Space> to start search
nnoremap <nowait> <Space> /

" YANK TEXT TO SYSTEM CLIPBOARD
nnoremap <Leader>y "+y

vnoremap <Leader>y "+y

nnoremap <Leader>Y "+Y
nnoremap <Leader>Y "+YY

nnoremap <Leader>d "_d
vnoremap <Leader>d "_d
inoremap <C-c> <Esc>
nnoremap Q <Nop>

" Keep cursor centered on half-page scroll
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
" Keep search results centered when navigating
nnoremap n nzzzv
nnoremap N Nzzzv

" Highlight yanked text briefly (40ms flash)
highlight YankHighlight guibg=#FBDE84 guifg=#000000 gui=bold
augroup YankColorScheme
  autocmd!
  autocmd ColorScheme * highlight YankHighlight guibg=#FBDE84 guifg=#000000 gui=bold
augroup END
augroup HighlightYank
  autocmd!
  autocmd TextYankPost * call s:HighlightOnYank()
augroup END

augroup ThePrimeagen
  autocmd!
  autocmd BufWritePre * %s/\s\+$//e
augroup END

function! s:HighlightOnYank() abort
  " Only react to yanks
  if get(v:event, 'operator', '') !=# 'y'
    return
  endif

  let s = getpos("'[")
  let e = getpos("']")

  if !exists('w:_yank_matches')
    let w:_yank_matches = []
  endif

  let id = -1
  " Charwise single-line: highlight exact range
  if s[1] == e[1] && get(v:event, 'regtype', 'v') ==# 'v'
    let len = max([1, e[2] - s[2] + 1])
    let id = matchaddpos('YankHighlight', [[s[1], s[2], len]], 10)
  else
    " Multi-line or linewise/blockwise: highlight full lines
    let pat = '\%>' . (s[1]-1) . 'l\%<' . (e[1]+1) . 'l'
    let id = matchadd('YankHighlight', pat, 10)
  endif

  call add(w:_yank_matches, id)
  call timer_start(40, function('s:ClearYankMatches'))
endfunction

function! s:ClearYankMatches(timer) abort
  if exists('w:_yank_matches')
    while !empty(w:_yank_matches)
      call matchdelete(remove(w:_yank_matches, 0))
    endwhile
  endif
endfunction

