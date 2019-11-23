# Arch installation script

Before invoke the **prechoot.sh** script. You must format the disk. Mount *home* and *boot*. Set up swap.

Gdisk tips: use `ef00` for EFI partition. `8200` for linux swap. `8300` for linux filesystem

```bash
lsblk
gdisk /dev/sdX

mkfs.vfat -F32 /dev/sdXN
mkswap /dev/sdXN
mkfs.ext4 /dev/sdXN
swapon /dev/sdXN

mount /dev/sdXN /mnt
mkdir /mnt/{boot,boot/efi,home}
mount /dev/sdXN /mnt/boot/efi
mount /dev/sdXN /mnt/home

pacman -Syy
pacman -S git
git clone https://github.com/clive2000/linux-install-ansible.git

cd linux-install-ansible
bash prechroot.sh
```
