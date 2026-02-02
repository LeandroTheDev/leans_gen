#!/bin/sh
echo "Installing OBS Studio..."
username=$(whoami)
cd "/home/$username"

if [ -x /usr/bin/paru ]; then
    paru -Sy obs-studio-browser

    # rm -rf "/home/$username/Temporary/obs-install.sh"
    # sudo rm -rf "/etc/skel/Temporary/obs-install.sh"

    clear
else
    echo "paru is required to install OBS Studio."
    read -p "Install it? [Y/n]" response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    if [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]]; then
        /home/$username/Temporary/paru-install.sh
        /home/$username/Temporary/obs-install.sh
    fi
fi