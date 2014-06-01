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

# livecd stuff
livecd: build/ubuntu-14.04-desktop-amd64.iso
	sudo ./build-livecd.sh build/ubuntu-14.04-desktop-amd64.iso build/darkbuntu-$(CHANGE)-$(BRANCH).iso
	rm build/darkbuntu-$(BRANCH).iso || true
	ln -s darkbuntu-$(CHANGE)-$(BRANCH).iso build/darkbuntu-$(BRANCH).iso

livecd_incremental:
	test -e darkbuntu-$(BRANCH).iso
	sudo ./build-livecd.sh build/darkbuntu-$(BRANCH).iso build/darkbuntu-$(BRANCH).iso
	rm build/darkbuntu-$(BRANCH).iso || true
	ln -s darkbuntu-$(CHANGE)-$(BRANCH).iso build/darkbuntu-$(BRANCH).iso

build/ubuntu-14.04-desktop-amd64.iso:
	wget 'http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-amd64.iso' \
		-O build/ubuntu-14.04-desktop-amd64.iso


.PHONY: install_latest pull clean provision all livecd livecd_incremental
