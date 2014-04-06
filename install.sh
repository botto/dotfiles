#!/bin/bash

# RUN AS ROOT TO INSTALL TO /etc/skel/ so new users have these dotfiles
# or sudo -u <user> ./install.sh to install as any other user

# Else will install to home dir

cd $(dirname $0)

# quit on error
#set -e
CHANGE=$(git rev-list HEAD --count)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
VERSION=$BRANCH-$CHANGE

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

# just the arguments (cryptic, I know. That's why you should use fish!)
PRESETS=$@

# make sure the submodules are fetched
#echo 'Synchronising submodules...'
#git submodule --quiet init || exit 1
#git submodule --quiet update || exit 2


echo 'Clobbering...'
# clobber vim and fish config (because there are dirs)
test -d ~/.vim/ && rm -rf ~/.vim/
# not for fish as it removes generated completions which have to rebuilt which is a pain
#test -d ~/.config/fish/ && rm -rf ~/.config/fish/

echo 'Copying dotfiles...'
#cp -r home/* ~ # non-dotfiles
# copy dotfiles separately , normal glob does not match
cp -r home/.??* ~

echo 'Copying scripts...'
cp -a bin ~
chmod +x ~/bin/*

if [ ! $(tput colors) -eq 256 ]; then
	warning "TERM '$TERM' is not a 256 colour type! Please set in terminal emulator. EG: Putty should have putty-256color, xterm should have xterm-256color."
fi

# reload TMUX config if running inside tmux
if [ -n "$TMUX" ]; then
	echo 'Reloading tmux configuration...'
	tmux source-file ~/.tmux.conf >/dev/null
else
	warning "Not inside tmux, so can't tell tmux to reload"
fi

if which fish &>/dev/null && fish -v 2>&1 | grep -q 'version 2'; then
	test ! -d ~/.config/fish/generated_completions/ \
		&& fish -c fish_update_completions
else
 	warning 'Fish shell version 2 not found. Bash it is, then...'
fi

if [ -n "$DISPLAY" ] && which xrdb &>/dev/null; then
	echo 'Merging Xresources...'
	xrdb -merge ~/.Xresources
else
	warning "X not configured. Now you can't enjoy the nice urxvt and xterm settings."
fi

# generate help files (well, tags) for the vim plugins
#if which vim &>/dev/null; then
#	echo 'Generating helptags for vim submodules...'
#	echo 'call pathogen#helptags()|q' | vim -es -n -T dumb
#else
#	warning 'Vim not found! Is your brain functioning correctly?'
#fi

#Not using submodules as we only want vundle once and then let it control itself
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle

echo $VERSION > ~/.botto-dotfiles-version

# in case someone forgot...
if [ $BRANCH == 'master' ]; then
	warning "Generic version installed from master branch. Make your own branch for user-specific things."
elif [ $BRANCH != $USER ]; then
	warning "Branch does not match user. Sure about this? The convention is to have a custom branch matching your username."
fi
