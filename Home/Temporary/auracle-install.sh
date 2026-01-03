#!/bin/sh
echo "Installing Auracle..."
username=$(whoami)
cd "/home/$username"

mkdir -p Temp
cd Temp
git clone https://aur.archlinux.org/auracle-git.git
cd auracle
makepkg -sic --noconfirm

# Deleting temporary folder
rm -rf "/home/$username/Temp"

# Deleting the script
rm -rf "/home/$username/Temporary/auracle-install.sh"
sudo rm -rf "/etc/skel/Temporary/auracle-install.sh"

clear