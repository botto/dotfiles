" Hide toolbar by default
set guioptions-=m
set guioptions-=T

if has('win32')
	set gfn=Consolas:h10:cANSI
elseif has('mac')
	set gfn=Menlo:h12:cANSI
  set guioptions=aAce
  set fuoptions=maxvert,maxhorz
  set noballooneval
  set fu

  " resize current buffer by +/- 5
  nnoremap <M-Right> :vertical resize +5<CR>
  nnoremap <M-Left>  :vertical resize -5<CR>
  nnoremap <M-Up>    :resize -5<CR>
  nnoremap <M-Down>  :resize +5<CR>
  let g:solarized_degrade=1
elseif has('unix')
	" Set the menutoolbar on gvim linux, otherwise pasting from X is a
	" pain
	set guioptions+=m
	"set gfn=DejaVu\ Sans\ Mono:h12:cANSI
endif


" Why does it open with GUI by default...?
let g:nerdtree_tabs_open_on_gui_startup=0


" default gvim is too small
set columns=160
set lines=160
