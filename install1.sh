#!/bin/sh

# Use timedatectl to ensure the system clock is accurate
timedatectl set-ntp true

parted --script /dev/sda \
       mklabel gpt \
       mkpart EFI-system-partition fat32 1MiB 513MiB \
       set 1 esp on \
       mkpart swap-partition linux-swap 513MiB 4609MiB \
       mkpart root-partition ext4 4609MiB 100%

mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
swapon /dev/sda2

# pacstrap is needed for the specified packages to be installed in the specified directory
pacstrap /mnt base base-devel linux linux-firmware amd-ucode grub efibootmgr
# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

cp ./install2.sh /mnt/home/
arch-chroot /mnt sh /home/install2.sh

rm /mnt/home/install2.sh
echo 'Setup Complete!'
umount -R /mnt
