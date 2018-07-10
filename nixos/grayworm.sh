#!/usr/bin/env bash


#-----------------------------------------------------------------------------#
# 1. Ensure
#-----------------------------------------------------------------------------#

diskdevice=$1

if [ "$diskdevice" = "" ]; then
    echo "ERROR: First argument should be disk device (eg. /dev/sda)."
    exit 1
fi


#-----------------------------------------------------------------------------#
# 1. Partition
#-----------------------------------------------------------------------------#
#
# Borrowed from
# https://github.com/techhazard/nixos-iso/blob/master/techhazard/partition.sh
#
# The actual command is below the comment block.
# we will create a new GPT table
#
# o:         create new GPT table
#         y: confirm creation
#
# with the new partition table,
# we now create the EFI partition
#
# n:         create new partion
#         1: partition number
#   <empty>: start position (default is 2048)
#     +512M: make it 512MB big
#      EF00: set an EFI partition type
#
# With the EFI partition, we
# use the rest of the disk for LUKS
#
# n:         create new partition
#         2: partition number
#   <empty>: start partition right after first
#   <empty>: use all remaining space
#      8300: set generic linux partition type
#
# We only need to set the partition labels 
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
gdisk ${diskdevice} >/dev/null <<end_of_commands
o
Y
n
1

512+
EF00
n
2
8300
c
1
efiboot
c
2
encryptedroot
w
y
end_of_commands
