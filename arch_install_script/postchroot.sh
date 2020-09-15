set -e

############################## In chroot #############################
pacman -Syy
pacman --noconfirm -S os-prober grub efibootmgr networkmanager openssh sudo

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

hwclock --systohc --utc

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
  ;;
esac

# Openvmtools

install_open_vm_tools() {
	pacman --noconfirm -S open-vm-tools xf86-video-vmware gtkmm3
	#cp /etc/vmware-tools/vmware-user.desktop /etc/xdg/autostart/vmware-user.desktop
	systemctl enable vmtoolsd.service
}

echo "Do you want to install a open_vm_tools?"
echo "  1)Yes"
echo "	2)No"

read n
case $n in
  1) install_open_vm_tools;;
  *) echo "Ok, Done";;
esac

install_additional_packages() {
	pacman --noconfirm -S python-pip git gcc zsh vim code docker htop tmux curl wget chromium firefox nano v2ray

	# Add user to docker group
	# Enable docker service
	usermod -aG docker xhuang
	systemctl enable docker.service

	# chsh for xhuang to zsh,install oh-my-zsh
	chsh -s /bin/zsh xhuang

	# Install fontconfig, zshrc and vimrc
sudo -i -u xhuang <<EOF
wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O install.sh
bash install.sh --unattended
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime;
sh ~/.vim_runtime/install_awesome_vimrc.sh;
mkdir -p /home/xhuang/.config/fontconfig;
wget -O /home/xhuang/.config/fontconfig/fonts.conf https://raw.githubusercontent.com/clive2000/dotfiles/master/.config/fontconfig/fonts.conf;
fc-cache --force;
EOF
}


while true; do
    read -p "Do you wish to install additional packages?" yn
    case $yn in
        [Yy]* ) install_additional_packages; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done