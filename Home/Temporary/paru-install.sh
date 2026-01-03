#!/bin/sh
echo "Installing Paru..."
username=$(whoami)
cd "/home/$username"

mkdir -p Temp
cd Temp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -sic --noconfirm

# Deleting temporary folder
rm -rf "/home/$username/Temp"

# Deleting the script
rm -rf "/home/$username/Temporary/paru-install.sh"
sudo rm -rf "/etc/skel/Temporary/paru-install.sh"

clear