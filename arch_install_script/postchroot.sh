set -x
set -e

############################## In chroot #############################
pacman -Syy
pacman --noconfirm -S vim os-prober grub efibootmgr networkmanager openssh sudo python-pip

sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

echo "Select Your location"
echo "  1)USA/CANADA"
echo "  2)China"

read n
case $n in
  1) ln -Sf /usr/share/zoneinfo/America/Toronto /etc/localtime;;
  2) ln -Sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;;
  *) ln -Sf /usr/share/zoneinfo/America/Toronto /etc/localtime;;
esac

hwclock –systohc –utc

case $(grep 'vendor_id' /proc/cpuinfo | head -1) in
	*AuthenticAMD*)
		pacman --noconfirm -S amd-ucode
		;;
	*GenuineIntel*)
		pacman --noconfirm -S intel-ucode xf86-video-intel
		;;
esac

mkinitcpio -p linux

echo 'xhuang' > /etc/hostname
echo '127.0.0.1	localhost.localdomain	localhost	 xhuang' > /etc/hosts

echo 'Setup a passwd for root'
until passwd root; do
	echo 'root passwd set failed, please retry'
	sleep 1
done

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

# User
useradd -m -g users -G wheel -s /bin/bash xhuang 
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
echo 'Setup a passwd for xhuang'
until passwd xhuang; do
	echo 'passwd setup failed, please retry'
	sleep 1
done

# GUI install

install_kde() {
	pacman --noconfirm -S xorg
	pacman --noconfirm -S mesa
	pacman --noconfirm -S plasma kde-applications sddm
	pacman --noconfirm -S noto-fonts noto-fonts-cjk ttf-ibm-plex
	systemctl enable sddm
}

install_xfce() {
	pacman --noconfirm -S xorg
	pacman --noconfirm -S mesa
	pacman --noconfirm -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
	pacman --noconfirm -S noto-fonts noto-fonts-cjk ttf-ibm-plex
	systemctl enable lightdm.service	
}


echo "Do you want to install a desktop environment?"
echo "  1)KDE"
echo "  2)Xfce"
echo "  3)No"

read n
case $n in
  1) install_kde;;
  2) install_xfce;;
  *) 
  echo "Done"
  exit
  ;;
esac