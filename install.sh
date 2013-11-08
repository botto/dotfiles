#!/bin/bash

# Usage: ./install.sh <preset> <preset> <...>
#
# Where preset is nothing (default) or a script in preset/

# RUN AS ROOT TO INSTALL TO /etc/skel/ so new users have these dotfiles
# or sudo -u <user> ./install.sh to install as any other user

# Put a list of pubkeys in pubkeys/user
# put specific setup scripts in specific/user

# quit on error
#set -e
VERSION=$(git rev-list HEAD --count)

cat <<EOF
### naggie/dotfiles, version $VERSION.

Dedpendencies:

  * tmux 1.8+
  * fish 2.0+ (recommended) or bash 3+
  * vim 7.3+
  * Dark 256color terminal with SGR1006 mouse support and UTF-8 character
    encoding for unicode character set

EOF

# this is good for log files
date
echo

function warning {
	# TODO: check PS1, no escape code if not interactive....?
	echo -e "\e[00;31m> $*\e[00m"
}

# sneaky hack to install to skel if run as root
if [ `whoami` == root ]; then
	HOME=/etc/skel
fi

cd $(dirname $0)

# just the arguments (cryptic, I know. That's why you should use fish!)
PRESETS=$@

# make sure the submodules are fetched
echo 'Synchronising submodules...'
git submodule --quiet init || exit 1
git submodule --quiet update || exit 2


echo 'Clobbering...'
# clobber vim and fish config (because there are dirs)
test -d ~/.vim/ && rm -rf ~/.vim/
# not for fish as it removes generated completions which have to rebuilt which is a pain
#test -d ~/.config/fish/ && rm -rf ~/.config/fish/

echo 'Copying dotfiles...'
cp -r home/* ~
# copy dotfiles separately , normal glob does not match
cp -r home/.??* ~
chmod +x ~/bin/*

if [ ! $(tput colors) -eq 256 ]; then
	warning "TERM '$TERM' is not a 256 colour type! Please set in terminal emulator. EG: Putty should have putty-256color, xterm should have xterm-256color."
fi

# reload TMUX config if running inside tmux
if [ -n "$TMUX" ]; then
	echo 'Reloading tmux configuration...'
	tmux source-file ~/.tmux.conf
else
	warning 'Not inside tmux'
fi

if which fish &>/dev/null && fish -v 2>&1 | grep -q 'version 2'; then
	test ! -d ~/.config/fish/generated_completions/ \
		&& fish -c fish_update_completions
else
	warning 'Fish shell version 2 not found'
fi

if [ -n "$DISPLAY" ] && which xrdb &>/dev/null; then
	echo 'Merging Xresources...'
	xrdb -merge ~/.Xresources
else
	warning 'X not configured'
fi

# generate help files (well, tags) for the vim plugins
if which vim &>/dev/null; then
	echo 'Generating helptags for vim submodules...'
	echo 'call pathogen#helptags()|q' | vim -es -n -T dumb
else
	warning 'Vim not found!'
fi

echo $VERSION > ~/.naggie-dotfiles-version

# in case someone forgot...
chmod +x presets/*
# oops, not README.md
chmod -x presets/README.md

# user-specific stuff
echo
if [ "$PRESETS" ]; then
	cd presets/
	for PRESET in ${PRESETS[@]}; do
		if [ -x "$PRESET" ]; then
			echo "Installing preset: $PRESET"
			source "$PRESET"
		else
			warning Invalid preset: $PRESET
		fi
	done
	cd ..
else
	warning 'No preset specified, default installed.'
	echo 'Run with ./install.sh <preset> <preset> ...'
	echo To load a prefix from presets/
fi

