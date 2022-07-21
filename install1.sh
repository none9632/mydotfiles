#!/bin/sh

devicelist="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)"
PS3="Select a disk: "
IFS="
"
select device in $devicelist
do
    if [ "$device" != "" ]
    then
        device=$(echo "$device" | awk '{print $1}')
        break
    fi
    echo "Wrong nuber"
done

# Use timedatectl to ensure the system clock is accurate
timedatectl set-ntp true

parted --script $device \
       mklabel gpt \
       mkpart EFI-system-partition fat32 1MiB 513MiB \
       set 1 esp on \
       mkpart swap-partition linux-swap 513MiB 4609MiB \
       mkpart root-partition ext4 4609MiB 100%

boot_partition="$(ls ${device}* | grep -E "^${device}p?1$")"
swap_partition="$(ls ${device}* | grep -E "^${device}p?2$")"
root_partition="$(ls ${device}* | grep -E "^${device}p?3$")"

mkfs.fat -F 32 $boot_partition
mkswap $swap_partition
mkfs.ext4 $root_partition

mount $root_partition /mnt
mkdir -p /mnt/boot/efi
mount $boot_partition /mnt/boot/efi
swapon $swap_partition

# pacstrap is needed for the specified packages to be installed in the specified directory
pacstrap /mnt base base-devel linux linux-firmware amd-ucode grub efibootmgr git cmake networkmanager
# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

cp ./install2.sh /mnt/home/
arch-chroot /mnt sh /home/install2.sh

rm /mnt/home/install2.sh
echo 'Setup Complete!'
umount -R /mnt
swapoff $swap_partition
