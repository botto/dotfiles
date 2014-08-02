status --is-interactive; or exit 0

set -x PATH ~/bin /usr/local/bin /usr/local/share/npm/bin $PATH

# sometimes TMUX can get confused about whether unicode is supported to draw
# lines or not. tmux may draw x and q instead, or default to - and | which is
# ascii. This also allows other programs to use nice UTF-8 symbols, such as
# NERDtree in vim. So very awesome.
set -x LANG=en_GB.utf8

# mac bc read the conf file to allow floating point maths
# and load the standard library
set -x BC_ENV_ARGS "$HOME/.bcrc -l"

# On some machines, hostname is not set. Using $(hostname) to do this is slow,
# so just read from /etc/hostname)
 test $HOSTNAME; or set -x HOSTNAME (cat /etc/hostname 2>/dev/null; or hostname)

# TERM TYPE Inside screen/tmux, it should be screen-256color -- this is
# configured in .tmux.conf.  Outside, it's up to you to make sure your terminal
# is configured to provide the correct, 256 color terminal type. For putty,
# it's putty-256color (which fixes a lot of things) and otherwise it's probably
# something like xterm-256color. Most, if not all off the terminals I use
# support 256 colors, so it's safe to force it as a last resort, but warn.
if begin; test -z $TMUX ; and test (tput colors) -ne 256; end
	set -x TERM xterm-256color
	set_color red
	echo "> TERM '$TERM' is not a 256 colour type! Overriding to xterm-256color. Please set. EG: Putty should have putty-256color."
	set_color normal
end

# only on new shell, fail silently. Must be non-invasive.
test ! $TMUX; and ~/bin/server-splash ^/dev/null

# sometimes TMUX can get confused about whether unicode is supported to draw
# lines or not. tmux may draw x and q instead, or default to - and | which is
# ascii. This also allows other programs to use nice UTF-8 symbols, such as
# NERDtree in vim. So very awesome.
set -x LANG=en_GB.utf8

# mac bc read the conf file to allow floating point maths
# and load the standard library
set -x BC_ENV_ARGS "$HOME/.bcrc -l"

# On some machines, hostname is not set. Using $(hostname) to do this is slow,
# so just read from /etc/hostname)
test $HOSTNAME; or set -x HOSTNAME (cat /etc/hostname 2>/dev/null; or hostname)

# AUTOMATIC TMUX
# must not launch tmux inside tmux (no memes please)
test -z $TMUX
	# installed?
	and which tmux > /dev/null ^&1
	# only attach if single session
	and test (tmux list-sessions 2>/dev/null | wc -l) -eq 1
	# don't attach if already attached elsewhere
	and test (tmux list-clients 2>/dev/null | wc -l) -eq 0
	# terminal must be wide enough
	and test (tput cols) -gt 119
	# only then is is safe to assume it's OK to jump in
	and tmux attach

# totally worth it
if not test -d ~/.config/fish/generated_completions/
	echo "One moment..."
	fish_update_completions
end


# vim -X = don't look for X server, which can be slow
set -x EDITOR 'vim -X'

set -x PAGER ~/bin/vimpager

# if you call a different shell, this does not happen automatically. WTF?
set -x SHELL (which fish)

# available since 4.8.0
set -x GCC_COLORS 1

# alias is just a wrapper for creating a function
# aliases shared between fish and bash
. ~/.aliases

# get new or steal existing tmux
function tm
	# must not already be inside tmux
	test ! $TMUX; or return
	# detach any other clients
	# attach or make new if there isn't one
	tmux attach -d; or tmux
end

# patches for Mac OS X
set PLATFORM (uname)
if test "$PLATFORM" = 'Darwin'
	alias ls='ls -G'
	#unalias ls
	# unalias is broken...
	#alias ls=ls
	set -x CLICOLOR 1
	set -x LSCOLORS gxBxhxDxfxhxhxhxhxcxcx
	# slightly different utf8 locale format...
	# see `locale -a`
	set -x LANG 'en_GB.UTF-8'
  # i like the graphical vim
  alias vim='mvim'
end

function cd
	builtin cd $argv
	and ls
end

test -x /usr/bin/keychain
	and test -r ~/.ssh/id_rsa
	and eval (keychain --nogui --quiet --eval ~/.ssh/id_rsa)

# these functions are too small to warrant a separate file
function fish_greeting
	echo \n\> Welcome to $HOSTNAME, $USER! Files in $PWD are:\n
	ls
	echo -e "\n> fish, dotfiles version "(cat ~/.naggie-dotfiles-version)
	echo '>'(uptime)
end


function fish_title --description 'Set terminal (not tmux) title'
	# title of terminal
	echo $HOSTNAME
end

function fish_tmux_title --description "Set the tmux window title"
	# to a clever shorthand representation of the current dir. minus whitespace
	echo $PWD | sed s/[^a-zA-Z0-9\/]/-/g | grep -oE '[^\/]+$'
end

# only auto set title based on initial pane
# this detects if the pane is the first in a new window (probably)
test $TMUX
	and test (tmux list-panes | wc -l) -eq 1
	and set -x TMUX_PRIMARY_PANE set

function fish_set_tmux_title --description "Sets tmux pane title to output of fish_tmux_title, with padding" --on-variable PWD
	# title of tmux pane, must be separate to fish_title
	# only run this if tmux is also running
	test $TMUX
		and test $TMUX_PRIMARY_PANE
		and printf "\\033k%s\\033\\\\" (fish_tmux_title)
end

function __fish_p4_prompt
	test $P4CLIENT; or return
	echo -n " ($P4CLIENT) "
end

function fish_prompt --description 'Write out the prompt'
	printf "\n\33[32m%s@%s \33[1;34m%s\33[0;33m%s\33[m\n\$ " \
		$USER $HOSTNAME $PWD (__fish_git_prompt)
end

function ssh --description 'SSH wrapper to magically LOCK tmux title to hostname, if tmux is running'
	if test $TMUX
		# find host from array (in a dumb way)
		set host $argv[-1]

		printf "\\033k%s\\033\\\\" $host
		tmux set -q allow-rename off
		command ssh $argv ; and clear
		tmux set -q allow-rename on
		fish_set_tmux_title
	else
		command ssh $argv ; and clear
	end
end

# initially set title
fish_set_tmux_title
