#!/usr/bin/env bash

# To install run: curl https://link.garbas.si/grayworm | sh
# Borrowed stuff from https://github.com/techhazard/nixos-iso/tree/master/techhazard


set -e
# DEBUG
# set -x

#-----------------------------------------------------------------------------#
# 1. Ensure
#-----------------------------------------------------------------------------#

diskdevice=$1
passphrase=$2

if [ "$diskdevice" = "" ]; then
    echo "ERROR: First argument should be disk device (eg. /dev/sda)."
    exit 1
fi

if [ "$passphrase" = "" ]; then
    echo "ERROR: Second argument should be passphrase for your root Luks partition."
    exit 1
fi

modprobe zfs || {
    echo "ERROR: Add 'boot.supportedFilesystems = [ \"zfs\" ];'"
    echo "       to /etc/nixos/configuration.nix"
    echo "       and run 'nixos-rebuild switch'"
    exit 1
}


#-----------------------------------------------------------------------------#
# 1. Partitioning
#-----------------------------------------------------------------------------#

# We will create a new GPT table:
#
# o:         create new GPT table
#         y: confirm creation
#
# With the new partition table, we now create the EFI partition:
#
# n:         create new partion
#         1: partition number
#   <empty>: start position (default is 2048)
#     +512M: make it 512MB big
#      EF00: set an EFI partition type
#
# With the EFI partition, we use the rest of the disk for LUKS:
#
# n:         create new partition
#         2: partition number
#   <empty>: start partition right after first
#   <empty>: use all remaining space
#      8300: set generic linux partition type
#
# We only need to set the partition labels:
#
# c:         change partition label
#         1: partition to label
#   efiboot: name of the partition
# c:         change partition label
#         2: partition to label
# cryptroot: name of the partition
# 
# w:	     write changes and quit
#         y: confirm write
echo -n "1. Partitioning ${diskdevice} ..."
gdisk ${diskdevice} >/dev/null <<end_of_commands
o
Y
n
1

+512M
EF00
n
2


8300
c
1
efiboot
c
2
cryptroot
w
y
end_of_commands

# check for the newly created partitions
# this sometimes gives unrelated errors
# so we change it to  `partprobe || true`
partprobe "${diskdevice}" >/dev/null || true

# wait for label to show up
while [[ ! -e /dev/disk/by-partlabel/efiboot ]];
do
	sleep 2;
done

# wait for label to show up
while [[ ! -e /dev/disk/by-partlabel/cryptroot ]];
do
	sleep 2;
done

# check if both labels exist
ls /dev/disk/by-partlabel/efiboot   >/dev/null
ls /dev/disk/by-partlabel/cryptroot >/dev/null

echo " DONE"



#-----------------------------------------------------------------------------#
# 2. Format EFI (boot) partition
#-----------------------------------------------------------------------------#

echo -n "2. Format EFI (boot) partition ..."

mkfs.vfat /dev/disk/by-partlabel/efiboot >/dev/null

echo " DONE"


#-----------------------------------------------------------------------------#
# 3. Format Luks (root) partition
#-----------------------------------------------------------------------------#

echo -n "3. Format Luks (root) partition ..."

# temporary keyfile, will be removed (8k, ridiculously large)
dd if=/dev/urandom of=/tmp/keyfile bs=1k count=8 &>/dev/null

# formats the partition with luks and adds the temporary keyfile.
echo "YES" | cryptsetup luksFormat /dev/disk/by-partlabel/cryptroot --key-size 512 --hash sha512 --key-file /tmp/keyfile

echo "$passphrase" | cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot --key-file /tmp/keyfile

# mount the cryptdisk at /dev/mapper/root
cryptsetup luksOpen /dev/disk/by-partlabel/cryptroot root -d /tmp/keyfile
# remove the temporary keyfile
cryptsetup luksRemoveKey /dev/disk/by-partlabel/cryptroot /tmp/keyfile
rm -f /tmp/keyfile

echo " DONE"


#-----------------------------------------------------------------------------#
# 4. Format ZFS pool (zroot)
#-----------------------------------------------------------------------------#

echo -n "4. Format ZFS pool (zroot) ..."

zpool create -O atime=off \
             -O compression=lz4 \
             -O normalization=formD \
             -O snapdir=visible \
             -O xattr=sa \
             -o ashift=12 \
             -o reservation=1G \
             -o altroot=/mnt \
            rpool /dev/mapper/root

mem="$(grep MemTotal /proc/meminfo | awk '{print $2$3}')"

zfs create -o mountpoint=none -o reservation=1G rpool/ROOT
zfs create -o mountpoint=legacy -o reservation=1G rpool/ROOT/NIXOS
zfs create -o mountpoint=legacy -o reservation=1G -o com.sun:auto-snapshot=true  rpool/HOME
zfs create -V "${mem}" -b $(getconf PAGESIZE) -o compression=zle -o logbias=throughput -o sync=always -o primarycache=metadata -o secondarycache=none -o com.sun:auto-snapshot=false rpool/SWAP

mkswap -L SWAP /dev/zvol/rpool/SWAP
swapon /dev/zvol/rpool/SWAP

echo " DONE"


#-----------------------------------------------------------------------------#
# 5. Mounting partitations /mnt, /mnt/boot, /mnt/home
#-----------------------------------------------------------------------------#

echo -n "5. Mounting partitations /mnt, /mnt/boot, /mnt/home ..."

mount -t zfs rpool/ROOT/NIXOS /mnt

mkdir -p /mnt/home
mount -t zfs rpool/HOME /mnt/home

mkdir -p /mnt/boot
mount /dev/disk/by-partlabel/efiboot /mnt/boot

zpool set bootfs="rpool/ROOT/NIXOS" rpool

echo " DONE"


#-----------------------------------------------------------------------------#
# 6. Checkout configuration and install NixOS
#-----------------------------------------------------------------------------#

mkdir -p /mnt/etc/nixos

pushd /mnt/etc/nixos
    if [ -e dotfiles ]; then
        git clone https://github.com/garbas/dotfiles
    else
        pushd dotfiles
            git pull
        popd
    fi

    if [ -e nixpkgs-channels ]; then
        git clone https://github.com/NixOS/nixpkgs-channels
    else
        pushd nixpkgs-channels
            git pull
        popd
    fi

    rm -f configuration.nix
    ln -s configuration.nix dotfiles/nixos/grayworm.nix
popd

nixos-install -I /mnt/etc/nixos/nixpkgs-channels
