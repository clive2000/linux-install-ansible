set -x
set -e


echo "Enabling NTP"
timedatectl set-ntp true

# Fastmirror
echo "Installing reflector"
pacman -Syy
pacman --noconfirm -S reflector

echo "Select Your location"
echo "  1)USA/CANADA"
echo "  2)China"

read n
case $n in
  1) reflector --country 'United States' --country Canada --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist;;
  2) reflector --country China --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist;;
  *) 
    echo "invalid option"
    echo "Exiting..."
    exit
    ;;
esac

pacman -Syy

# Do not use -i flag (-i means run interactively)
echo "pacstrap install to /mnt"
pacstrap /mnt base linux linux-firmware 

# fstab
echo "Generating fstab"
genfstab -U /mnt > /mnt/etc/fstab

cp postchroot.sh /mnt/root
arch-chroot /mnt /bin/bash /root/postchroot.sh


