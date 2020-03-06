#!/bin/bash

loadkeys ru	
setfont cyr-sun16

echo 'System Clock Sync'
timedatectl set-ntp true

echo 'Create partitions'
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +100M;

  echo n;
  echo;
  echo;
  echo;
  echo +20G;

  echo n;
  echo;
  echo;
  echo;
  echo +1G;

  echo n;
  echo p;
  echo;
  echo;
  echo a;
  echo 1;

  echo w;
) | fdisk /dev/sda

echo 'Disk formatting'
(
  echo y;
) | mkfs.ext2  /dev/sda1 -L boot

(
  echo y;
) | mkfs.ext4  /dev/sda2 -L root

(
  echo y;
) | mkswap /dev/sda3 -L swap

(
  echo y;
) | mkfs.ext4  /dev/sda4 -L home

echo 'Mount drives'
mount /dev/sda2 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda3
mount /dev/sda4 /mnt/home

echo 'The choice of mirrors to download.'
pacman -Sy --noconfirm --noprogressbar --quiet reflector
reflector --verbose --country Kazakhstan --country Russia -p https --sort rate --save /etc/pacman.d/mirrorlist

echo 'Installing major packages'
pacstrap /mnt linux base nano dhcpcd netctl sudo wget

echo 'System Setup'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/aka-dekrain/arch2018/master/arch2.sh)"
