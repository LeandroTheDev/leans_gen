#!/bin/sh
username=$(whoami) 

cd /home/$username/System/Softwares

# Downloading flutter
git clone -b main https://github.com/flutter/flutter.git
mv ./flutter ./Flutter

# Downloading dependencies
sudo pacman -S cmake ninja clang --noconfirm

# Global variables
echo "export PATH=\"/home/$username/System/Softwares/Flutter/bin:\$PATH\"" >> /home/$username/System/Scripts/global-variables.sh
echo "export CHROME_EXECUTABLE=/usr/bin/chromium" >> /home/$username/System/Scripts/global-variables.sh

# Deleting the script
rm -rf "/home/$username/Temporary/flutter-install.sh"
sudo rm -rf "/etc/skel/Temporary/flutter-install.sh"