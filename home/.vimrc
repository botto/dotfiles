" vim 7.3+
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'

" themes
Plugin 'altercation/vim-colors-solarized'
Plugin 'nanotech/jellybeans.vim'

" Bundles
Plugin 'tpope/vim-fugitive'
Plugin 'vim-scripts/trailing-whitespace'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'ap/vim-css-color'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'kien/ctrlp.vim'
Plugin 'Lokaltog/powerline-fonts'
Plugin 'joonty/vdebug'
Plugin 'genoma/vim-less'
Plugin 'majutsushi/tagbar'
Plugin 'airblade/vim-gitgutter'

Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'Xuyuanp/nerdtree-git-plugin'

Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

filetype plugin indent on
syntax on

" It's not the 70's anymore. Use git or something.
set noswapfile
set nobackup

set backspace=indent,eol,start
" make arrow keys wrap lines and whitespace properly
set whichwrap=b,s,<,>,[,]
set number
set smartcase

" indenting
set autoindent
set smartindent
set expandtab
set smarttab

" Two spaces for life
set shiftwidth=2
set tabstop=2

" Lets kill those bells
set noerrorbells
set novisualbell
set t_vb=
autocmd! GUIEnter * set vb t_vb=

" Search
set ic
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

au BufNewFile,BufRead *.json    set filetype=javascript
au BufNewFile,BufRead *.less    set filetype=css
au BufNewFile,BufRead *.cls     set filetype=tex
au BufNewFile,BufRead *.ino     set filetype=c
au BufNewFile,BufRead *.pde     set filetype=c
au BufNewFile,BufRead *.md      set filetype=markdown
au BufNewFile,BufRead *.fish    set filetype=sh
au BufNewFile,BufRead *.fdc     set filetype=sdc
au BufNewFile,BufRead .aliases  set filetype=sh
au BufNewFile,BufRead .bcrc     set filetype=bc
" Drupal files are 80 cols wide only
au BufNewFile,BufRead *.install set filetype=php colorcolumn=80
au BufNewFile,BufRead *.module  set filetype=php colorcolumn=80
au BufNewFile,BufRead *.theme   set filetype=php colorcolumn=80
au BufNewFile,BufRead *.test    set filetype=php colorcolumn=80


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
" Get off my lawn
" https://github.com/thoughtbot/dotfiles/blob/master/vimrc
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

let g:SuperTabNoCompleteAfter = ['^', '\s', '//', '#']

" This is so that we can automate the vundle install
if ! empty(globpath(&rtp, 'bundle/jellybeans.vim/colors/jellybeans.vim'))
  colorscheme jellybeans
  set background=light
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
ca 'q q
ca q; q
ca qq q
ca W  w
ca Q  q
ca Wqaz wqa
ca Wqqa wqa
ca Wqa  wqa
ca WQa  wqa
ca WQA  wqa

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

" Nope, never use macros...plugins anyone?
"map q <Nop>

" re-flow entire paragraph
nmap Q gqap

" http://nvie.com/posts/how-i-boosted-my-vim/
" Finally, a trick by Steve Losh "for when you forgot to sudo before editing a
" file that requires root privileges (typically /etc/hosts). This lets you use
" w!! to do that after you opened the "file already:
cmap w!! w !sudo tee % >/dev/null

" Enable mouse mode. Use xterm >= 277 for mouse mode for large terms.
"set mouse=a

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

" Press F2 to magically fold everything
map <F2> :set foldmethod=indent<CR><CR>

map <F3> :Retab<CR><CR>
map <F4> :!p4 edit %<CR><CR>:w<CR><CR>
map <F6> :SyntasticCheck<CR><CR>
map <F7> :FixWhitespace<CR><CR>
map <F8> :sort<CR><CR>
" toggle wrap/paste
map <F9>  :set wrap!<CR><CR>
map <F10> :set paste!<CR><CR>

" airline is lighter than powerline.
" Old powerline colours are nice.
let g:airline_theme='powerlineish'
let g:airline_left_sep=''
let g:airline_right_sep=''

" Unsurprisingly, I want to edit dotfiles and simlinks!
let g:ctrlp_show_hidden = 1
let g:ctrlp_follow_symlinks = 1

" to bottom if log
au BufNewFile,BufRead *.log normal G

" abort a merge commit
ca fail cq

" stop accidentally saving ';' or ':' files due to typo
" http://stackoverflow.com/questions/6210946/prevent-saving-files-with-certain-names-in-vim
autocmd BufWritePre [:;]* throw 'Forbidden file name: ' . expand('<afile>')

" set vdebug to local
let g:vdebug_options = {
      \'server': '0.0.0.0'
      \}

" Syntax coloring lines that are too long just slows down the world
" http://superuser.com/questions/302186/vim-scrolls-very-slow-when-a-line-is-too-long
set synmaxcol=256
" give the terminal many characters-per-second it it can cope
set ttyfast
" only draw on user input
set lazyredraw

