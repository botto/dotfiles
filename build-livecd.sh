#!/bin/bash

# Builds darksky ubuntu (naggie/dotfiles based) which is a custom live CD.
# See example grub.cfg in etc/ to boot from a flash drive.
# Uses current branch.

# Incremental approach, using an existing ISO.

# Use the 'toram' kernel parameter. The result is a super-fast, disposable
# environment!
#
# Based on https://help.ubuntu.com/community/LiveCDCustomization

# Install pre-requisities
#aptitude install squashfs-tools genisoimage

BRANCH=$(git rev-parse --abbrev-ref HEAD)
NAME="darkbuntu-$BRANCH"

UBUNTU_ISO_URL='http://www.ubuntu.com/start-download?distro=desktop&bits=64&release=latest'
SOURCE='ubuntu-13.10-desktop-amd64.iso'
TARGET="$NAME.iso"

# TODO: sort out what happens when not run in this dir

# Modes of operation:
#
# 1. Source and Target non-existant: New source is downloaded, target is compiled
# 2. Target exists: Target is used as source
# 3. Just source exists: New target is created

function WARNING {
	# TODO: check PS1, no escape code if not interactive....?
	echo -e "\e[00;31m> $*\e[00m"
}

if [ `whoami` != root ]; then
	WARNING Run as root
	exit
fi

if [ -f "$TARGET" ]; then
	SOURCE="$TARGET"
elif [ ! -f "$SOURCE" ]; then
	wget "$UBUNTU_ISO_URL" -O "$SOURCE" || exit 2
fi

echo
echo SOURCE: $SOURCE
echo TARGET: $TARGET
echo
echo


# check dependencies
if ! which mkisofs mksquashfs &> /dev/null; then
	WARNING 'Error! required genisoimage and/or squashfs-tools package(s) are not installed'
	exit
fi

if [ $(uname -m) != x86_64 ]; then
	WARNING 'Error! x86_64 architecture required.'
	exit
fi

# less typing, with environment variables set
function INSIDE {
	chroot build/root \
		/usr/bin/env \
		HOME=/root \
		LC_ALL=C \
		USER=root \
		"$@"
}

function BREAKPOINT {
	INSIDE /bin/bash
}

# remove all trace of building in a safe way on termination
# might fail if things are not there yet, but that's fine.
function EMERGENCY_CLEANUP {
	echo Emergency cleanup...
	umount -l build/root/proc
	umount    build/root/sys
	umount -l build/root/dev
	umount    build/root/dev/pts
	umount    build/mnt
	exit
}

# always clean up on CTRL+C
trap EMERGENCY_CLEANUP SIGINT

# DEBUG
#set -x

[ -d build ] || mkdir build/

# echo commands to aid debugging
set -x

# clean
rm -rf build/*

mkdir build/mnt
mount -o loop,ro "$SOURCE" build/mnt

# extract ISO so files are writable
mkdir build/extract
rsync --exclude=/casper/filesystem.squashfs -a build/mnt/ build/extract

# Extract the Desktop system
# Extract the SquashFS filesystem
unsquashfs -no-progress -d build/root build/mnt/casper/filesystem.squashfs

# Prepare and chroot
# network connection within chroot
cp /etc/resolv.conf build/root/etc/
cp /etc/hosts       build/root/etc/

# other filesystems, inside chroot
# these mount important directories of your host system - if you later decide to
# delete the edit/ directory, then make sure to unmount before doing so,
# otherwise your host system will become unusable at least temporarily until
# reboot)
# Also rm -rf'ing over binded dev really isn't a good thing...
mount -t proc   none build/root/proc
mount -t sysfs  none build/root/sys
mount -t devpts none build/root/dev/pts
mount --bind /dev/   build/root/dev

# In 9.10, (+?) before installing or upgrading packages you need to run
# also may as well update/upgrade and add repositories
dbus-uuidgen | INSIDE tee /var/lib/dbus/machine-id
INSIDE dpkg-divert --local --rename --add /sbin/initctl
INSIDE ln -s /bin/true /sbin/initctl
INSIDE add-apt-repository universe
INSIDE add-apt-repository multiverse

INSIDE ln -s /lib/init/upstart-job /etc/init.d/whoopsie # required, otherwise apt breaks

# Utterly stupid hack required to fix keyboard map for X on livecd.
sed -i -re "s/'en': *'us',/'en': 'gb',/g" \
	build/root/usr/lib/ubiquity/ubiquity/misc.py

yes | INSIDE apt-get update
yes | INSIDE apt-get install git


#BREAKPOINT

# install packages
# and dotfiles
# naggie/dotfiles does this all
# installs dotfiles to /etc/skel/ so that live (ubuntu) user will get a
#cp -a ../dotfiles build/root/root/
#git clone . build/root/root/dotfiles
# rsync preserves original origin and submodules, but git submodules have
# absolute references which break if you move the git folder on old versions of
# git...
#rsync -r --exclude=build --exclude='*iso' "$DOTFILES_DIR" build/root/root/dotfiles
INSIDE /bin/bash -x <<EOF
	git clone git://github.com/naggie/dotfiles.git
	cd dotfiles
	git checkout $BRANCH
	cd provision
	yes | ./ubuntu-13.10-desktop
	cd ..
	./install.sh
	cd ..
EOF


# edit variables in /etc/casper.conf for distro/host/username

# CLEANUP
# Be sure to remove any temporary files which are no longer needed, as space on a
# CD is limited. A classic example is downloaded package files, which can be
# cleaned out using:
#INSIDE aptitude clean

# New kernel?
#cp build/root/boot/vmlinuz-2.6.15-26-k7    build/extract/casper/vmlinuz
#cp build/root/boot/initrd.img-2.6.15-26-k7 build/extract/casper/initrd.gz
# After you've modified the kernel, init scripts or added new kernel
# modules, you need to rebuild the initrd.gz file and substitute it into
# the casper directory.
#INSIDE mkinitramfs -o /initrd.gz 2.6.15-26-k7
#mv edit/initrd.gz extract-cd/casper/

yes | INSIDE apt-get upgrade # just in case it's not already done
yes | INSIDE apt-get clean
yes | INSIDE apt-get autoremove

#BREAKPOINT

rm -rf build/root/tmp/*
rm     build/root/.bash_history

rm build/root/etc/hosts
rm build/root/etc/resolv.conf

# Clean after installing software
rm build/root/var/lib/dbus/machine-id
rm build/root/sbin/initctl
INSIDE dpkg-divert --rename --remove /sbin/initctl

# now umount (unmount) special filesystems before creation of iso
umount -l build/root/proc
umount    build/root/sys
umount -l build/root/dev
umount    build/root/dev/pts
umount    build/mnt

# ASSEMBLE ISO
chmod +w build/extract/casper/filesystem.manifest

INSIDE dpkg-query -W --showformat='${Package} ${Version}\n' > build/extract/casper/filesystem.manifest

cp build/extract/casper/filesystem.manifest build/extract/casper/filesystem.manifest-desktop

sed -i '/ubiquity/d' build/extract/casper/filesystem.manifest-desktop
sed -i '/casper/d'   build/extract/casper/filesystem.manifest-desktop

# Compress filesystem
# already excluded by rsync
#rm build/extract/casper/filesystem.squashfs

# For a highest possible compression at the cost of compression time, you may
# use the xz method and is better exclude the edit/boot directory altogether:
#mksquashfs build/root/ build/extract/casper/filesystem.squashfs
mksquashfs \
	build/root build/extract/casper/filesystem.squashfs \
	-comp xz -e build/root/boot -no-progress

# Update the filesystem.size file, which is needed by the installer:
printf $(du -sx --block-size=1 build/root | cut -f1) > build/extract/casper/filesystem.size

# Set an image name in extract-cd/README.diskdefines
#vim extract-cd/README.diskdefines

# recalc hashes
rm build/extract/md5sum.txt
# subshell, no chdir persistence
echo 'Calculating hashes...'
(
	cd build/extract
	find -type f -print0 \
		| xargs -0 md5sum \
		| grep -v isolinux/boot.cat \
		> md5sum.txt
)

# Create the ISO image
mkisofs -D -r -V "$NAME" -cache-inodes -J -l \
	-b isolinux/isolinux.bin \
	-c isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 \
	-boot-info-table \
	-o "$TARGET" build/extract/

# clean, MUST MAKE SURE EVERYTHING IS UNMOUNTED FIRST, PARTICULARLY /dev
rm -rf build/*

# yay git
#touch build/.empty

# postprocess to allow simple dd to flash drive to work?
# isohybrid
# http://manpages.ubuntu.com/manpages/natty/man1/isohybrid.1.html

# Example: burn the image to CD with:
#cdrecord dev=/dev/cdrom ubuntu-9.04-desktop-i386-custom.iso

# could order files to reduce seeking time. But not normally used from CD any more.
# http://lichota.net/~krzysiek/projects/kubuntu/dapper-livecd-optimization/

