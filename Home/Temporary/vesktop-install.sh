#!/bin/sh
echo "Installing Vesktop..."
username=$(whoami)
cd "/home/$username"

mkdir -p Temp
cd Temp
git clone https://aur.archlinux.org/vesktop.git
cd vesktop
makepkg -sic --noconfirm

# Deleting temporary folder
rm -rf "/home/$username/Temp"

# Deleting the script
rm -rf "/home/$username/Temporary/vesktop-install.sh"
sudo rm -rf "/etc/skel/Temporary/vesktop-install.sh"

clear