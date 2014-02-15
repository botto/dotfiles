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

UBUNTU_ISO_URL='http://www.ubuntu.com/start-download?distro=desktop&bits=64&release=latest'
SOURCE='ubuntu-13.10-desktop-amd64.iso'
TARGET="darkbuntu-$BRANCH.iso"
BUILD_DIR='build'
DOTFILES_DIR=$(dirname $0)

# TODO: sort out what happens when not run in this dir

# Modes of operation:
#
# 1. Source and Target non-existant: New source is downloaded, target is compiled
# 2. Target exists: Target is used as source
# 3. Just source exists: New target is created

if [ `whoami` != root ]; then
	echo Run as root
	exit
fi

if [ -f "$TARGET" ]; then
	SOURCE="$TARGET"
elif [ ! -f "$SOURCE" ]; then
	wget "$UBUNTU_ISO_URL" -O "$SOURCE" || exit 2
fi

echo SOURCE: $SOURCE
echo TARGET: $TARGET
echo



# check dependencies
if ! which mksquashfs &> /dev/null; then
	echo '> Error! required squashfs-tools package is not installed'
	exit
fi

if ! which mkisofs &> /dev/null; then
	echo '> Error! required genisoimage package is not installed'
	exit
fi

# less typing, with environment variables set
function INSIDE {
	chroot "$BUILD_DIR"/root \
		/usr/bin/env \
		HOME=/root \
		LC_ALL=C \
		USER=root \
		"$@"
}

# remove all trace of building in a safe way on termination
# might fail if things are not there yet, but that's fine.
function EMERGENCY_CLEANUP {
	echo Emergency cleanup...
	umount -l "$BUILD_DIR"/root/proc
	umount    "$BUILD_DIR"/root/sys
	umount -l "$BUILD_DIR"/root/dev
	umount    "$BUILD_DIR"/root/dev/pts
	umount    "$BUILD_DIR"/mnt
	exit
}

# always clean up on CTRL+C
trap EMERGENCY_CLEANUP SIGINT

# DEBUG
#set -x

[ -d "$BUILD_DIR" ] || mkdir "$BUILD_DIR"/

# clean
rm -rf "$BUILD_DIR"/*

mkdir "$BUILD_DIR"/mnt
mount -o loop,ro "$SOURCE" "$BUILD_DIR"/mnt

# extract ISO so files are writable
mkdir "$BUILD_DIR"/extract
rsync --exclude=/casper/filesystem.squashfs -a "$BUILD_DIR"/mnt/ "$BUILD_DIR"/extract

# Extract the Desktop system
# Extract the SquashFS filesystem
unsquashfs -no-progress -d "$BUILD_DIR"/root "$BUILD_DIR"/mnt/casper/filesystem.squashfs

# Prepare and chroot
# network connection within chroot
cp /etc/resolv.conf "$BUILD_DIR"/root/etc/
cp /etc/hosts       "$BUILD_DIR"/root/etc/

# other filesystems, inside chroot
# these mount important directories of your host system - if you later decide to
# delete the edit/ directory, then make sure to unmount before doing so,
# otherwise your host system will become unusable at least temporarily until
# reboot)
# Also rm -rf'ing over binded dev really isn't a good thing...
mount -t proc   none "$BUILD_DIR"/root/proc
mount -t sysfs  none "$BUILD_DIR"/root/sys
mount -t devpts none "$BUILD_DIR"/root/dev/pts
mount --bind /dev/ "$BUILD_DIR"/root/dev

# In 9.10, (+?) before installing or upgrading packages you need to run
# also may as well update/upgrade and add repositories
dbus-uuidgen | INSIDE tee /var/lib/dbus/machine-id
INSIDE dpkg-divert --local --rename --add /sbin/initctl
INSIDE ln -s /bin/true /sbin/initctl
INSIDE add-apt-repository universe
INSIDE add-apt-repository multiverse

# get a shell inside the chroot (debug)
#INSIDE /bin/bash

yes | INSIDE apt-get update
yes | INSIDE apt-get install aptitude git

# When you want to remove packages remember to use purge
INSIDE aptitude purge libreoffice

#yes | INSIDE apt-get remove --purge 'libreoffice*'

yes | INSIDE apt-get upgrade

# install packages
# and dotfiles
# naggie/dotfiles does this all
# installs dotfiles to /etc/skel/ so that live (ubuntu) user will get a
#cp -a ../dotfiles "$BUILD_DIR"/root/root/
#git clone . "$BUILD_DIR"/root/root/dotfiles
# rsync preserves original origin and submodules, but git submodules have
# absolute references which break if you move the git folder on old versions of
# git...
#rsync -r --exclude="$BUILD_DIR" --exclude='*iso' "$DOTFILES_DIR" "$BUILD_DIR"/root/root/dotfiles
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
INSIDE aptitude clean
INSIDE apt-get clean
INSIDE apt-get autoremove


rm -rf "$BUILD_DIR"/root/tmp/*
rm     "$BUILD_DIR"/root/.bash_history

rm "$BUILD_DIR"/root/etc/hosts
rm "$BUILD_DIR"/root/etc/resolv.conf

# Clean after installing software
rm "$BUILD_DIR"/root/var/lib/dbus/machine-id
rm "$BUILD_DIR"/root/sbin/initctl
INSIDE dpkg-divert --rename --remove /sbin/initctl

# now umount (unmount) special filesystems before creation of iso
umount -l "$BUILD_DIR"/root/proc
umount    "$BUILD_DIR"/root/sys
umount -l "$BUILD_DIR"/root/dev
umount    "$BUILD_DIR"/root/dev/pts
umount    "$BUILD_DIR"/mnt

# ASSEMBLE ISO
chmod +w "$BUILD_DIR"/extract/casper/filesystem.manifest

INSIDE dpkg-query -W --showformat='${Package} ${Version}\n' > "$BUILD_DIR"/extract/casper/filesystem.manifest

cp "$BUILD_DIR"/extract/casper/filesystem.manifest "$BUILD_DIR"/extract/casper/filesystem.manifest-desktop

sed -i '/ubiquity/d' "$BUILD_DIR"/extract/casper/filesystem.manifest-desktop
sed -i '/casper/d'   "$BUILD_DIR"/extract/casper/filesystem.manifest-desktop

# Compress filesystem
# already excluded by rsync
#rm "$BUILD_DIR"/extract/casper/filesystem.squashfs

# For a highest possible compression at the cost of compression time, you may
# use the xz method and is better exclude the edit/boot directory altogether:
#mksquashfs "$BUILD_DIR"/root/ "$BUILD_DIR"/extract/casper/filesystem.squashfs
mksquashfs \
	"$BUILD_DIR"/root "$BUILD_DIR"/extract/casper/filesystem.squashfs \
	-comp xz -e "$BUILD_DIR"/root/boot -no-progress

# Update the filesystem.size file, which is needed by the installer:
printf $(du -sx --block-size=1 "$BUILD_DIR"/root | cut -f1) > "$BUILD_DIR"/extract/casper/filesystem.size

# Set an image name in extract-cd/README.diskdefines
#vim extract-cd/README.diskdefines

# recalc hashes
rm "$BUILD_DIR"/extract/md5sum.txt
# subshell, no chdir persistence
(
	cd "$BUILD_DIR"/extract
	find -type f -print0 \
		| xargs -0 md5sum \
		| grep -v isolinux/boot.cat \
		| tee md5sum.txt
)

# Create the ISO image
mkisofs -D -r -V "Darkbuntu" -cache-inodes -J -l \
	-b isolinux/isolinux.bin \
	-c isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 \
	-boot-info-table \
	-o "$TARGET" "$BUILD_DIR"/extract/

# clean, TODO MUST MAKE SURE EVERYTHING IS UNMOUNTED FIRST, PARTICULARLY /dev
rm -rf "$BUILD_DIR"/*

# yay git
#touch "$BUILD_DIR"/.empty

# postprocess to allow simple dd to flash drive to work?
# isohybrid
# http://manpages.ubuntu.com/manpages/natty/man1/isohybrid.1.html

# Example: burn the image to CD with:
#cdrecord dev=/dev/cdrom ubuntu-9.04-desktop-i386-custom.iso

# could order files to reduce seeking time. But not normally used from CD any more.
# http://lichota.net/~krzysiek/projects/kubuntu/dapper-livecd-optimization/

