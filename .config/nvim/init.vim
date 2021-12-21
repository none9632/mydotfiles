call plug#begin('~/.config/nvim/bundle')

Plug 'jiangmiao/auto-pairs'
Plug 'easymotion/vim-easymotion'
Plug '907th/vim-auto-save'
Plug 'ryanoasis/vim-devicons'
Plug 'ap/vim-css-color'
Plug 'preservim/nerdcommenter'
Plug 'lambdalisue/suda.vim'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'lyokha/vim-xkbswitch'

Plug 'joshdick/onedark.vim'
Plug 'itchyny/lightline.vim'

Plug 'preservim/nerdtree', { 'on' : 'NERDTreeToggle' }
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'

Plug 'lervag/vimtex'
Plug 'sirver/ultisnips'
Plug 'KeitaNakamura/tex-conceal.vim', { 'for' : 'tex' }
Plug 'Konfekt/FastFold'

" Plug 'skywind3000/asyncrun.vim'

call plug#end()

set tabstop=4
set shiftwidth=4
set smartindent
set expandtab

set number
set wildmenu
set hlsearch
set incsearch
set ignorecase
set smartcase
set cursorline

filetype plugin indent on
set encoding=utf-8
syntax on

" Turn backup off, since most stuff is in SVN, git etc. anyway...
set nobackup
set nowb
set noswapfile

set so=7
set nowrap

set showcmd

"Autosave
let g:auto_save = 1
let g:auto_save_silent = 1

"Отображение пробелов и табуляции
set list
set listchars=tab:→\ ,space:·

autocmd FileType * setlocal formatoptions-=o

" .rasi syntax highlighting
au BufNewFile,BufRead /*.rasi setf css
au BufNewFile,BufRead /*.fish setf bash

" set spell
" set spelllang=en_us,ru_ru
" inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" Russian keymap
" au VimEnter * set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0

set timeoutlen=200

let g:mapleader=' '

nnoremap U <C-r>
nnoremap <C-r> U

nnoremap n N
nnoremap N n

imap jj <Esc>
imap оо <Esc>

"Switching between splits.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"split creation
nmap <Leader>l <C-w>v<C-w>l:Files<CR>
nmap <Leader>j <C-w>s<C-w>j:Files<CR>

nmap dA d$
nmap dI d0

map J }
map K {
map L w
map H b

"Copy/Paste to clipboard
map <C-c> "+y
map <C-p> "+P

"exit and close
map <Leader>q :q<CR>
map <C-x><C-c> :qa<CR>

"vim-plug
map <Leader>pi :source $HOME/.config/nvim/init.vim<CR>:PlugInstall<CR>
map <Leader>pd :source $HOME/.config/nvim/init.vim<CR>:PlugClean<CR>

"Easy motion
map /        <Plug>(easymotion-overwin-f2)
map <Space>w <Plug>(esymotion-bd-w)

"suda.vim
command! W execute 'SudaWrite' <bar> edit!

" set g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', "`":"`"}

" vimtex
let g:tex_flavor = 'latex'
" let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_view_method = 'zathura'
let g:vimtex_view_forward_search_on_start = 1
let g:vimtex_quickfix_mode = 0
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_quickfix_autoclose_after_keystrokes = 3
let g:vimtex_fold_enabled = 1
let g:vimtex_fold_types = {
      \ 'markers' : {'enabled': 0},
      \ 'sections' : {'parse_levels': 1},
      \}
let g:vimtex_complete_enabled = 1
let g:vimtex_complete_close_braces = 1
let g:vimtex_complete_ignore_case = 1
let g:vimtex_complete_smart_case = 1
let g:vimtex_format_enabled = 1

" KeitaNakamura/tex-conceal.vim
set conceallevel=2
let g:tex_conceal="abdmg"
hi Conceal ctermbg=none

" au BufNewFile,BufRead /*.tex VimtexCompile
map <leader>c :VimtexCompile<CR>
map <leader>e :VimtexErrors<CR>
map <leader>f :VimtexView<CR>
nnoremap <Enter> za

" Close viewers when VimTeX buffers are closed
function! CloseViewers()
    " Close viewers on quit
    if executable('xdotool') && exists('b:vimtex')
        \ && exists('b:vimtex.viewer') && b:vimtex.viewer.xwin_id > 0
        call system('xdotool windowclose '. b:vimtex.viewer.xwin_id)
    endif
endfunction

let mywindowid=system('xdotool getwindowfocus')

augroup vimtex_event
    au!
    " au User VimtexEventInitPost VimtexCompile
    au User VimtexEventCompileSuccess call system('xdotool windowfocus ' . mywindowid)
    au User VimtexEventCompileFailed call system('xdotool windowfocus ' . mywindowid)
    au User VimtexEventView call system('xdotool windowfocus ' . mywindowid)
    au User VimtexEventQuit call CloseViewers()
augroup END

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
" inoremap <silent><expr> <Tab>
inoremap <silent><expr> <A-j>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><A-k> pumvisible() ? "\<C-p>" : "\<C-h>"
" inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-tab>'

set background=dark
colorscheme onedark

highlight Normal           ctermfg=15      ctermbg=none  cterm=none
highlight CursorLineNr     ctermfg=7       ctermbg=0     cterm=none
highlight CursorLine       ctermfg=none    ctermbg=0     cterm=none

let g:lightline = {
    \ 'colorscheme' : 'deus',
    \ }

" We don't need to see things like -- INSERT -- anymore
set noshowmode

map <C-n> :NERDTreeToggle<CR>

"let g:NERDTreeDirArrowExpandable  = '>'
"let g:NERDTreeDirArrowCollapsible = '˅'
let g:NERDTreeShowHidden          = get(g:, 'NERDTreeShowHidden', 1)

"let g:NERDTreeMapCustomOpen = get(g:, 'NERDTreeMapCustomOpen', '<Tab>')
"let g:NERDTreeMapCustomOpen = get(g:, 'NERDTreeMapCustomOpen', '<CR>')
let g:NERDTreeMapOpenSplit  = get(g:, 'NERDTreeMapOpenSplit',  '<Space>j')
let g:NERDTreeMapOpenVSplit = get(g:, 'NERDTreeMapOpenVSplit', '<Space>l')

let g:NERDSpaceDelims = 1       " Add spaces after comment delimiters by default

map <Space>/ <Plug>NERDCommenterToggle

" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

map <C-f> :Files<CR>
map <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>
nnoremap <leader>t :Tags<CR>
nnoremap <leader>m :Marks<CR>

tmap <M-k> <C-k>
tmap <M-j> <C-j>

let g:fzf_tags_command = 'ctags -R'
" Border color
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }

let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline -e'
let $FZF_DEFAULT_COMMAND="rg --files --hidden"

" Customize fzf colors to match your color scheme
let g:fzf_colors =
    \ { 'fg':      ['fg', 'Normal'],
    \   'bg':      ['bg', 'Normal'],
    \   'hl':      ['fg', 'Comment'],
    \   'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
    \   'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
    \   'hl+':     ['fg', 'Statement'],
    \   'info':    ['fg', 'PreProc'],
    \   'border':  ['fg', 'Ignore'],
    \   'prompt':  ['fg', 'Conditional'],
    \   'pointer': ['fg', 'Exception'],
    \   'marker':  ['fg', 'Keyword'],
    \   'spinner': ['fg', 'Label'],
    \   'header':  ['fg', 'Comment'] }

"Get Files
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)

" Get text in files with Rg
command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
    \   fzf#vim#with_preview(), <bang>0)

" Ripgrep advanced
function! RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

" Git grep
command! -bang -nargs=* GGrep
    \ call fzf#vim#grep(
    \   'git grep --line-number '.shellescape(<q-args>), 0,
    \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
