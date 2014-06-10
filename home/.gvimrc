" Hide toolbar by default
set guioptions-=m
set guioptions-=T

if has('win32')
	set gfn=Consolas:h10:cANSI
elseif has('mac')
	set gfn=Menlo:h12:cANSI
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
