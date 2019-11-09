timedatectl set-ntp true

# Fastmirror
pacman -Syy
pacman -S reflector
reflector --country 'United States' --country Canada --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

# Do not use -i flag (-i means run interactively)
pacstrap /mnt base linux linux-firmware 

# fstab
genfstab -U /mnt » /mnt/etc/fstab

cp postchroot.sh /mnt/root

arch-chroot /mnt /bin/bash


