#!/bin/sh
echo "Installing Waterfox..."
username=$(whoami)
cd "/home/$username"

mkdir -p Temp
cd Temp
git clone https://aur.archlinux.org/waterfox-bin.git
cd waterfox
makepkg -sic --noconfirm

# Deleting temporary folder
rm -rf "/home/$username/Temp"

# Deleting the script
rm -rf "/home/$username/Temporary/waterfox-install.sh"
sudo rm -rf "/etc/skel/Temporary/waterfox-install.sh"

clear