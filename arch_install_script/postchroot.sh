
############################## In chroot #############################
pacman -Syy
pacman --noconfirm -S vim os-prober grub efibootmgr networkmanager openssh sudo

sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

ln -Sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock –systohc –utc

case $(grep 'vendor_id' /proc/cpuinfo | head -1) in
	*AuthenticAMD*)
		pacman --noconfirm -S amd-ucode
		;;
	*GenuineIntel*)
		pacman --noconfirm -S intel-ucode
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

