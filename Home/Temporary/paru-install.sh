#!/bin/sh

echo "Installing Paru..."
username=$(whoami)
cd "/home/$username"

mkdir -p Temp
cd Temp

echo ""
echo "How do you want to install Paru?"
echo "1) Compile from source (recommended, always up-to-date)"
echo "2) Use prebuilt binary (faster, good for slow computers, may be outdated)"
read -p "Choose an option [1/2]: " choice

choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

if [[ "$choice" == "2" || "$choice" == "binary" ]]; then
    echo ""
    echo "You chose the prebuilt binary. WARNING: it may be outdated and not work correctly, but it's faster for slow computers."
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    makepkg -sic --noconfirm
elif [[ "$choice" == "1" || "$choice" == "compile" || -z "$choice" ]]; then
    echo ""
    echo "You chose to compile from source (recommended)."
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -sic --noconfirm
else
    echo "Invalid option. Exiting."
    exit 1
fi

# Deleting temporary folder
rm -rf "/home/$username/Temp"

# Deleting the script
# rm -rf "/home/$username/Temporary/paru-install.sh"
# sudo rm -rf "/etc/skel/Temporary/paru-install.sh"

clear
echo "Paru installation completed!"