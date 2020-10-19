" Misc {{{
" --------
tnoremap <ESC> <C-\><C-n>
let mapleader="\<SPACE>"


" Plugins setup {{{
" -----------------
let g:plug_threads=4
call plug#begin('~/.local/share/nvim/plugged')

" Git integration for the lightline.vim plugin
Plug 'itchyny/vim-gitbranch'

" Minimal and useful status line
Plug 'itchyny/lightline.vim'

function! RenderFileType()
	return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction
function! RenderFileFormat()
	return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction
function! RenderTabName(name)
	let l:filename = lightline#tab#filename(a:name)
	return (WebDevIconsGetFileTypeSymbol(l:filename) . ' ' . l:filename)
endfunction

let g:lightline = {
	\ 'enable': {
	\   'statusline': 1,
	\   'tabline': 1,
	\ },
	\ 'colorscheme': 'seoul256',
	\ 'active': {
	\   'left': [[ 'mode', 'paste' ],
	\            [ 'gitbranch', 'readonly', 'relativepath', 'modified' ]]
	\ },
	\ 'inactive': {
	\   'left': [[ 'readonly', 'relativepath', 'modified' ]]
	\ },
	\ 'tabline': {
	\   'left': [[ 'tabs' ]],
	\   'right': [[ 'close' ]]
	\ },
  \ 'tab' : {
  \   'active': [ 'rendertab' ],
  \   'inactive': [ 'rendertab' ],
  \ },
  \ 'tab_component_function' : {
  \   'rendertab': 'RenderTabName',
  \ },
	\ 'component_function': {
	\   'gitbranch': 'gitbranch#name',
	\   'filetype': 'RenderFileType',
	\   'fileformat': 'RenderFileFormat',
	\ },
	\ }

" Window selector
Plug 't9md/vim-choosewin'
nmap <Leader>ws <Plug>(choosewin)

" Fuzzy search buffers, files, history, colors, etc...
if has('mac')
	set runtimepath+=/usr/local/opt/fzf
endif
Plug 'junegunn/fzf.vim'
nnoremap , :Buffers<CR>
nnoremap ; :Files<CR>

" Search and replace
let g:esearch = {
	\ 'adapter': 'rg',
	\ 'backend': 'nvim',
	\ 'out': 'win',
	\ 'batch_size': 2048,
	\ 'use': ['visual', 'hlsearch', 'last'],
	\ 'default_mappings': 1,
	\}
Plug 'eugen0329/vim-esearch' " Trigger with <Leader>ff

" File system explorer
let g:NERDTreeMinimalUI = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['.git','.DS_Store']
let g:NERDTreeHighlightFolders = 1
let g:NERDTreeHighlightCursorline = 0
Plug 'preservim/nerdtree'
Plug 'her/synicons.vim'
nnoremap <Leader>wn :NERDTreeToggle<CR>
nnoremap <Leader>wf :NERDTreeFind<CR>

" Code commenting
Plug 'preservim/nerdcommenter'
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDTrimTrailingWhitespace = 1

" Smooth scrolling
Plug 'terryma/vim-smooth-scroll'
if has('unix') || has('mac')
	noremap <silent> <C-u> :call smooth_scroll#up(&scroll, 9, 2)<CR>
	noremap <silent> <C-d> :call smooth_scroll#down(&scroll, 9, 2)<CR>
	noremap <silent> <C-b> :call smooth_scroll#up(&scroll*2, 9, 4)<CR>
	noremap <silent> <C-f> :call smooth_scroll#down(&scroll*2, 9, 4)<CR>
endif

" Highlighting
let g:vim_json_syntax_conceal = 0
let g:vim_markdown_folding_disabled = 1
Plug 'godlygeek/tabular' " required for vim-markdown
Plug 'peterrincker/vim-searchlight'
Plug 'sheerun/vim-polyglot'

" Code completion and navigation
let g:coc_global_extensions = [ 'coc-calc', 'coc-clangd', 'coc-cmake', 'coc-css',
                              \ 'coc-go', 'coc-html', 'coc-json', 'coc-python',
                              \ 'coc-sh', 'coc-tsserver', 'coc-vimlsp', 'coc-vetur',
                              \ 'coc-yaml' ]
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Editor configuration
Plug 'editorconfig/editorconfig-vim'
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:WebDevIconsUnicodeGlyphDoubleWidth = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
Plug 'ryanoasis/vim-devicons'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

if has('win32')
	Plug 'gruvbox-community/gruvbox', { 'tag': 'v2.1.0' }
endif

call plug#end()
" }}} Plugins setup


" Indentation {{{
" ---------------
autocmd BufEnter,BufNewFile,BufRead * setlocal formatoptions=jql
set cindent
set cinoptions=:0,=1s,b1,g0,N0,(0,u0,U0)
set copyindent

" Default indentation.
" A good explanation of the meaning of the following
" commands is available at: https://tedlogan.com/techblog3.html and
" http://vimcasts.org/episodes/tabs-and-spaces
set noexpandtab
set shiftwidth=4
set smarttab
set softtabstop=0
set tabstop=4


" User Interface {{{
" ------------------
set nocursorline
set guicursor=a:block-blink0,
			\i:ver25-blinkwait150-blinkoff150-blinkon150
set ignorecase
set listchars=eol:¬,tab:\|\ ,space:·
set mouse=a
set nolist
set noshowmode
set wrap
set number
set relativenumber
autocmd FileType fzf set nonumber norelativenumber
set ruler
set scrolloff=8
set showbreak=↳\ 
set sidescroll=1
set smartcase
set splitbelow
set splitright

if has('unix') && exists('g:GuiLoaded')
	colorscheme slate
elseif has('unix') || has('mac')
	colorscheme default
	set background=light
else
	colorscheme gruvbox
	set background=dark
endif

syntax on

hi clear SignColumn
hi CocCalcFormule ctermfg=black ctermbg=green
hi link CocErrorFloat Pmenu
hi CocHighlightText ctermfg=black ctermbg=green
hi link CocWarningFloat Pmenu
hi CocWarningSign ctermfg=yellow
hi ColorColumn ctermfg=none ctermbg=darkgrey
hi CursorLineNR cterm=reverse
hi Error ctermfg=black ctermbg=red
hi ErrorMsg ctermfg=black ctermbg=red
hi Folded ctermfg=none ctermbg=darkgrey
hi Pmenu ctermfg=lightgrey ctermbg=238
hi PmenuSel ctermfg=black ctermbg=yellow
hi PmenuSBar ctermfg=lightgrey ctermbg=darkgrey
hi PmenuThumb ctermfg=none ctermbg=lightgrey
hi Search ctermfg=black ctermbg=darkblue
hi SearchLight ctermfg=black ctermbg=yellow
hi SpellBad ctermfg=black ctermbg=red
hi SpellCap ctermfg=black ctermbg=blue
hi TrailingWhitespaces ctermbg=red
hi VertSplit cterm=none
hi Visual ctermfg=black ctermbg=gray

match TrailingWhitespaces /\s\+$/
autocmd BufWinEnter * match TrailingWhitespaces /\s\+$/
autocmd InsertEnter * match TrailingWhitespaces /\s\+\%#\@<!$/
autocmd InsertLeave * match TrailingWhitespaces /\s\+$/
autocmd BufWinLeave * call clearmatches()
autocmd ColorScheme * hi TrailingWhitespaces ctermbg=red guibg=red

set completeopt+=menuone,noselect,noinsert
set omnifunc=syntaxcomplete#Complete
" }}} User Interface


" Functions, key mappings and other utils {{{
" -------------------------------------------
augroup netwr_key_mappings
	autocmd!
	autocmd filetype netrw call s:MapNetrwKeys()
augroup END
function! s:MapNetrwKeys()
	noremap _ :b#<CR>
endfunction

" Window navigation and zoom
nnoremap <Leader>wh <C-w>h
nnoremap <Leader>wj <C-w>j
nnoremap <Leader>wk <C-w>k
nnoremap <Leader>wl <C-w>l
nnoremap <Leader>w<S-h> <C-w><S-h>
nnoremap <Leader>w<S-j> <C-w><S-j>
nnoremap <Leader>w<S-k> <C-w><S-k>
nnoremap <Leader>w<S-l> <C-w><S-l>
nnoremap <Leader>wz1 :NERDTreeClose<CR> <C-w>_ <bar> <C-w>\|
nnoremap <Leader>wz0 <C-w>=

" coc chords
nnoremap <silent> <Leader>gd :call CocActionAsync('jumpDeclaration')<CR>
nnoremap <silent> <Leader>gf :call CocActionAsync('jumpDefinition')<CR>
nnoremap <silent> <Leader>gh :call CocActionAsync('highlight')<CR>
nnoremap <silent> <Leader>gi :call CocActionAsync('jumpImplementation')<CR>
nnoremap <silent> <Leader>gn :call CocActionAsync('diagnosticNext')<CR>
nnoremap <silent> <Leader>gm :call CocActionAsync('doHover')<CR>
nnoremap <silent> <Leader>gp :call CocActionAsync('diagnosticPrevious')<CR>
nnoremap <silent> <Leader>gr :call CocActionAsync('jumpReferences')<CR>
nnoremap <silent> <Leader>gs :CocCommand clangd.switchSourceHeader<CR>
nnoremap <silent> <Leader>gt :call CocActionAsync('jumpTypeDefinition')<CR>
nnoremap <silent> <Leader>gu :call CocActionAsync('rename')<CR>

function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~ '\s'
endfunction
inoremap <silent><expr> <Tab>
	\ pumvisible() ? "\<C-n>" :
	\ <SID>check_back_space() ? "\<Tab>" :
	\ coc#refresh()

" Tabs-related mappings
nnoremap th :tabfirst<CR>
nnoremap tl :tablast<CR>
nnoremap tj :tabprev<CR>
nnoremap tk :tabnext<CR>
nnoremap te :tabedit<Space>
nnoremap tn :tabnew<CR>
nnoremap tm :tabmove<Space>
nnoremap td :tabclose<CR>

" Search-related mappings
function! RipgrepFzf(query, fullscreen)
	let command_fmt = 'rg --column --line-number --no-heading --hidden --color=always --smart-case  --glob !\.git/ -- %s || true'
	let initial_command = printf(command_fmt, shellescape(a:query))
	let reload_command = printf(command_fmt, '{q}')
	let spec = {'options': ['--delimiter', ':', '--nth', '2..', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
	call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

function! FilterHistory(expr)
	call filter(v:oldfiles, 'v:val !~ "COMMIT_EDITMSG"')
	call filter(v:oldfiles, 'v:val =~ ' . '"' . a:expr . '"')
endfunction

nnoremap <Leader>ss :set spell<CR>
nnoremap <Leader>sc :noh<CR>:set nospell<CR>
nnoremap <Leader>sh :call FilterHistory(getcwd())<CR>:History<CR>
nnoremap <Leader>seg :RG<CR>
nnoremap <Leader>seb :BLines<CR>
nnoremap <Leader>sef :Lines<CR>
nnoremap <Leader>sw :RG <C-r><C-w><CR>
nnoremap <Leader>st :Tags <C-r><C-w><CR>
nnoremap <Leader>sd :call fzf#run(fzf#wrap({'source': 'fd --type d'}))<CR>
" Equal to * and # except that the cursor position isn't changed.
"" Improved upon https://stackoverflow.com/a/4823111
nnoremap * :keepjumps normal! msHmt`s*`tzt`s<CR>
nnoremap # :keepjumps normal! msHmt`s#`tzt`s<CR>
nnoremap <A-f> :%s/
inoremap <A-f> <ESC>:%s/

" Visualisation-related mappings
nnoremap <Leader>vn1 :set number<CR>
nnoremap <Leader>vl1 :set list<CR>
nnoremap <Leader>vc1 :set colorcolumn=101<CR>
nnoremap <Leader>vc2 :set colorcolumn=121<CR>
nnoremap <Leader>vs1 :syntax on<CR>
nnoremap <Leader>vn0 :set nonumber<CR>
nnoremap <Leader>vl0 :set nolist<CR>
nnoremap <Leader>vc0 :set colorcolumn=0<CR>
nnoremap <Leader>vs0 :syntax off<CR>

" Other navigation mappings
nnoremap - :e .<CR>
nnoremap _ :bp <CR>
nnoremap <A-n> <A-}>
nnoremap <A-b> <A-{>
inoremap <C-q> <ESC>:x<CR>
nnoremap <C-q> :x<CR>
inoremap <C-s> <ESC>:up<CR>i<Right>
nnoremap <C-s> <ESC>:up<CR>
inoremap <C-a> <ESC>:wa<CR>i<Right>
nnoremap <C-a> <ESC>:wa<CR>

" autocmd filetype html inoremap < <><Left>
" autocmd filetype html inoremap </ </><Left>

" Automatically jump to the last known position when re-opening a file
if has("autocmd")
	au BufWinEnter *
		\	if line("'\"") > 0 && line("'\"") <= line("$") |
		\		exe "normal! g`\" zz" |
		\	endif
endif
" }}} Functions, key mappings and other utils

" Automatically load NERDTree and FZF History when starting Neovim.
let vimenter_blacklist = ['gitcommit']
autocmd VimEnter * if index(vimenter_blacklist, &ft) < 0 && expand('%:t') == '' |
	\ NERDTreeToggle | :exe "normal \<C-w>l" |
	\ :call FilterHistory(getcwd()) | History

" Automatically exit if the last window is NERDTree
" Take from https://github.com/preservim/nerdtree#how-can-i-close-vim-if-the-only-window-left-open-is-a-nerdtree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Automatically reload a file if it has changed on disk.
" Taken from https://unix.stackexchange.com/a/383044
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed. Buffer was reloaded." | echohl None
