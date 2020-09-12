#!/bin/bash

set -e

read -p "Please tell me which device you want to partiion:" device_name
read -p "How much swap do you want to use. Please type in size in GiB:" swap_size

# Erase 
sgdisk -og $device_name

# Create 512MiB EFI
sgdisk -n 1:2048:+512MiB -t 1:ef00 $device_name

# Create swap
STARTSECTOR=`sgdisk -F $device_name`
sgdisk -n 2:"$STARTSECTOR":+"$swap_size"GiB -t 2:8200 $device_name

# Create Root
STARTSECTOR=`sgdisk -F $device_name`
ENDSECTOR=`sgdisk -E $device_name`
sgdisk -n 3:"$STARTSECTOR":"$ENDSECTOR" -t 3:8300 $device_name

sgdisk -p $device_name

# Format
mkfs.vfat -F32 "$device_name"1
mkswap "$device_name"2
mkfs.ext4 "$device_name"3
swapon "$device_name"2

# Mount 
mount "$device_name"3 /mnt
mkdir /mnt/{boot,boot/efi,home}
mount "$device_name"1 /mnt/boot/efi


