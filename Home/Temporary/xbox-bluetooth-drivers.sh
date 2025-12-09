#!/bin/sh
echo "Installing Xbox Bluetooth Controller Drivers..."
username=$(whoami)
cd "/home/$username"

mkdir Temp
cd Temp
git clone https://aur.archlinux.org/xpadneo-dkms-git.git
cd xpadneo-dkms-git
makepkg -sic --noconfirm

# Deleting temporary folder
rm -rf "/home/$username/Temp"

# Deleting the script
rm -rf "/home/$username/Temporary/xbox-bluetooth-drivers.sh"
sudo rm -rf "/etc/skel/Temporary/xbox-bluetooth-drivers.sh"

clear