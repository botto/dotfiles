" vim 7.3+
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'k

" Bundles
Plugin 'tpope/vim-fugitive'
Plugin 'nanotech/jellybeans.vim'
Plugin 'Lokaltog/vim-powerline'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-scripts/trailing-whitespace'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'ap/vim-css-color'
Plugin 'Valloric/YouCompleteMe'
Plugin 'joonty/vdebug'

filetype plugin indent on

set laststatus=2

" http://tooky.co.uk/2010/04/08/there-was-a-problem-with-the-editor-vi-git-on-mac-os-x.html
" If this causes vim to exit with non-zero and breaks git on OS X, investigate.
syntax on

"let g:Powerline_symbols = 'fancy'

set backspace=indent,eol,start
" make arrow keys wrap lines and whitespace properly
set whichwrap=b,s,<,>,[,]
set number
set ic
set smartcase
set autoindent
set incsearch

" no wrapping by default. Use `:set wrap` to re-enable
set nowrap

" match by highlight as well (still need to press return to search, however)
set hlsearch
" Clear search highlight by hitting enter
nnoremap <silent> <CR> :noh<CR>

" Spell checking. Does not offer suggestions :-)
set spell

" Highlight current line
set cursorline
" ...and column. Good for lining up and feeling like a pro hacker.
set cursorcolumn

au BufNewFile,BufRead *.json   set filetype=javascript
au BufNewFile,BufRead *.less   set filetype=css
au BufNewFile,BufRead *.ino    set filetype=c
au BufNewFile,BufRead *.pde    set filetype=c
au BufNewFile,BufRead *.md     set filetype=markdown
au BufNewFile,BufRead *.fish   set filetype=sh
au BufNewFile,BufRead *.fdc    set filetype=sdc
au BufNewFile,BufRead .aliases set filetype=sh
au BufNewFile,BufRead .bcrc    set filetype=bc

" It's not the 70's anymore. Use git or something.
set noswapfile
set nobackup

" get rid of the engulfing behavior of highlighting matching brackets
" when inside parenthesis. It makes the cursor hard to distinguish.
set noshowmatch


" NoMatchParen " this works as a command but not a setting
" this does work, fooling the matching system into
let loaded_matchparen = 1


" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" no point in pressing/releasing the shift key!
nnoremap ; :

" if you want to force yourself to use hjkl, uncomment this:
"map <up> <nop>
"map <down> <nop>
"map <left> <nop>
"map <right> <nop>

let g:SuperTabNoCompleteAfter = ['^', '\s', '//', '#']

" 16-color terminal with solarised theme is most accurate
" failing this, the following option can be set to use a degraded 256 color palette
let g:solarized_termcolors=256

" I like the degraded color scheme, even on gvim
let g:solarized_degrade=1

" good on crap laptop monitors (yes, not recommended by Mr. Schoonover)
let g:solarized_contrast="high"

set background=dark

if (&t_Co == 256)
	colorscheme solarized
endif

" anti typo (command aliases)
ca WQ wq
ca Wq wq
ca wQ wq
ca qw wq
ca Wqa wqa
ca W w
ca Q q
ca q1 q!

" <tab> to toggle nerdtree, persistent across all tabs with vim-nerdtree-tabs!
" or, choose standard NERDtree
nnoremap <tab> :NERDTreeTabsToggle<CR>
"nnoremap <tab> :NERDTreeToggle<CR>
let NERDTreeMapQuit='\t'
" when changing to a tab, file should be focused
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeWinSize = 40

" gf opens the file under cursor, which is great for navigating a hierarchy of files.
" Change gF to open file under cursor in new tab, not new pane, like CTRL+W gF
nnoremap gF <C-w>gf

" Ex mode? WTF VIM?
map Q <Nop>

" macros are extremely useful in rare cases, best not to disable
"map q <Nop>

" re-flow entire paragraph
nmap Q gqap

" http://nvie.com/posts/how-i-boosted-my-vim/
" Finally, a trick by Steve Losh "for when you forgot to sudo before editing a
" file that requires root privileges (typically /etc/hosts). This lets you use
" w!! to do that after you opened the "file already:
cmap w!! w !sudo tee % >/dev/null

" Enable mouse mode. Use xterm >= 277 for mouse mode for large terms.
set mouse=a

" abbreviations
ab teh the
ab THe The
ab eb be

" max. number of tabs open at once. I use a large term.
set tabpagemax=50

" open help in new tab
cabbrev help tab help

" abbreviate messages in every way to avoid hit-enter prompt
set shortmess=a

" keep window split size emal on resize AWESOME
" http://stackoverflow.com/questions/14649698/how-to-resize-split-windows-in-vim-proportionally
autocmd VimResized * :wincmd =

" Enable extended regular expressions by default on search. Also makes it
" consistent with :%s//g commands.
" This stops having to escape all regex metachars
set magic
nnoremap / /\v
cnoremap s/ s/\v

" some plugins/commands/aliases assume bash
set shell=bash

" Normal-mode backspace to toggle (exuberant) ctags tagbar (this is nice,
" similar to how tab does NERDtree
" DISABLED, not useful enough at the moment
"nnoremap <BS> :TagbarToggle<CR>

" some emacs/readline style normal mode nav that is hardcoded to my brain
map <C-a> <Home>
map <C-e> <End>
noremap! <C-a> <Home>
noremap! <C-e> <End>

" 4 spaces for tabs, inserted automatically.
" Tabs work fine in an ideal world. Sadly, spaces are always more consistent.
" To refactor code: find ./ -type f -exec sed -i 's/\t/    /g' {} \;
"set shiftwidth=4
"set expandtab

" Tabs (actual tabs) to be 4-wide. MOAR CODE ON SCREEN. Sorry, Linus. (block
" indent broken)
"set tabstop=4

" Press F2 to magically fold everything
map <F2> :set foldmethod=indent<CR><CR>
