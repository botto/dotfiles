BRANCH=`git rev-parse --abbrev-ref HEAD`
CHANGE=`git rev-list HEAD --count`
# Automatically update and install if fast-forward merge is possible
install_latest: pull install

install:
	./install.sh
pull:
	git fetch origin $(BRANCH)
	git merge --ff-only FETCH_HEAD
clean:
	git clean -dxf

provision:
	sudo provision/auto.sh

all: pull provision install

.PHONY: install_latest pull clean provision all livecd livecd_incremental
