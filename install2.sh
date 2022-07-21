#!/bin/sh

# Set the time zone
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
# Set the Hardware Clock from the System Clock and update the timestamps in /etc/adjtime
hwclock --systohc

sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i -e 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "myPC" > /etc/hostname
echo '127.0.0.1 localhost
::1 localhost
127.0.1.1   myPC.localdomain   myPC' >> /etc/hosts

echo 'Set root password'
passwd
read -p "Enter username: " name
useradd -m $name
echo "Set password for $name"
passwd $name
usermod -aG wheel,audio,video,optical,storage $name

# sudo configuration
sed -i -e 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
echo "$name myPC= NOPASSWD: /usr/bin/yay -Syy,/usr/bin/pacman -Sql" >> /etc/sudoers
# pacman configuration
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
sed -i -e 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

# network configuration
systemctl enable NetworkManager

# grub-install --target=i386-pc /dev/sda
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
