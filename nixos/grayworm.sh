#!/usr/bin/env bash

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

#-----------------------------------------------------------------------------#
# 1. Partitioning
#-----------------------------------------------------------------------------#
#
# Borrowed from
# https://github.com/techhazard/nixos-iso/blob/master/techhazard/partition.sh
#
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

mkfs.vfat /dev/disk/by-partlabel/efiboot

echo " DONE"


#-----------------------------------------------------------------------------#
# 3. Format Luks (root) partition
#-----------------------------------------------------------------------------#

echo -n "3. Format Luks (root) partition ..."

# temporary keyfile, will be removed (8k, ridiculously large)
dd if=/dev/urandom of=/tmp/keyfile bs=1k count=8

# formats the partition with luks and adds the temporary keyfile.
echo "YES" | cryptsetup luksFormat /dev/disk/by-partlabel/cryptroot --key-size 512 --hash sha512 --key-file /tmp/keyfile

echo "$passphrase" | cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot --key-file /tmp/keyfile

# mount the cryptdisk at /dev/mapper/nixroot
cryptsetup luksOpen /dev/disk/by-partlabel/cryptroot nixroot -d /tmp/keyfile
# remove the temporary keyfile
cryptsetup luksRemoveKey /dev/disk/by-partlabel/cryptroot /tmp/keyfile
rm -f /tmp/keyfile

echo " DONE"
