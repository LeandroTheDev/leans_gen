#!/bin/sh
echo "Installing Xbox Bluetooth Controller Drivers..."
username=$(whoami)
cd "/home/$username"

if [ -x /usr/bin/paru ]; then
    paru -Sy xpadneo-dkms-git

    # rm -rf "/home/$username/Temporary/xbox-bluetooth-drivers.sh"
    # sudo rm -rf "/etc/skel/Temporary/xbox-bluetooth-drivers.sh"

    clear
else
    echo "paru is required to install Xbox Drivers."
    read -p "Install it? [Y/n]" response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    if [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]]; then
        /home/$username/Temporary/paru-install.sh
        /home/$username/Temporary/xbox-bluetooth-drivers.sh
    fi
fi