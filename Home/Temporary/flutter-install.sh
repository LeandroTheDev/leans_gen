#!/bin/sh
echo "Installing Flutter..."
username=$(whoami)
cd "/home/$username"

mkdir -p Temp
cd Temp
git clone https://aur.archlinux.org/flutter-bin.git
cd flutter-bin
makepkg -sic --noconfirm

# Deleting temporary folder
rm -rf "/home/$username/Temp"

# Deleting the script
#rm -rf "/home/$username/Temporary/flutter-install.sh"
#sudo rm -rf "/etc/skel/Temporary/flutter-install.sh"

clear