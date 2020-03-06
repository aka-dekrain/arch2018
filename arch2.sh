#!/bin/bash

echo 'Set root password'
passwd

echo 'We register the computer name and username'

read -p "Enter computer name: " hostname
read -p "Enter username: " username

useradd -m -g users -G wheel -s /bin/bash $username

echo 'Set user password'
passwd $username

echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Asia/Almaty /etc/localtime

echo 'Add Russian system locale'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo 'Update the current system locale'
locale-gen

echo 'Specify the system language'
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
echo 'KEYMAP=ru' > /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'Uncomment the multilib repository. For 32-bit applications to work on a 64-bit system.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy --noconfirm --noprogressbar --quiet 

echo 'Install the bootloader'
pacman -S grub --noconfirm --noprogressbar --quiet  
grub-install /dev/sda

echo 'Update grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Install SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo "Where do we install Arch Linux on a virtual machine?"
read -p "1 - Yes, 0 - No: " vm_setting
if [[ $vm_setting == 0 ]]; then
 pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm --noprogressbar --quiet 
elif [[ $vm_setting == 1 ]]; then
  (
   echo 13;
   echo 2;
  ) | pacman -S xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils --noconfirm --noprogressbar --quiet 
fi

echo 'Create a bootable RAM disk'
mkinitcpio -p linux

echo "Install KDE & SLiM"
pacman -Sy plasma-meta kdebase slim --noconfirm --noprogressbar --quiet 
systemctl enable slim.service

echo 'Install font'
pacman -S ttf-liberation ttf-dejavu --noconfirm --noprogressbar --quiet  

echo 'Install network'
pacman -S networkmanager network-manager-applet ppp --noconfirm --noprogressbar --quiet 

echo 'We connect autoload of the login manager and the Internet'
systemctl enable NetworkManager
systemctl enable dhcpcd

#echo 'Installation AUR (yay)'
#sudo pacman -Syu

#mkdir ~/downloads
#cd ~/downloads

#wget git.io/yay-install.sh && sh yay-install.sh --noconfirm

#rm -rf ~/downloads

echo 'Installation completed! Reboot the system.'
exit
