#!/bin/sh
echo "Installing Flutter..."
username=$(whoami)
cd "/home/$username"

if [ -x /usr/bin/paru ]; then
    echo ""
    echo "How do you want to install Flutter?"
    echo "1) Compile from source (recommended, always up-to-date)"
    echo "2) Use prebuilt binary (faster, good for slow computers, may be outdated)"
    echo "3) Ignore Installation"
    read -p "Choose an option [1/2]: " choice

    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$choice" == "2" || "$choice" == "binary" ]]; then
        paru -Sy flutter-bin
    elif [[ "$choice" == "1" || "$choice" == "compile" || -z "$choice" ]]; then
        paru -Sy flutter    
    fi

    # rm -rf "/home/$username/Temporary/flutter-install.sh"
    # sudo rm -rf "/etc/skel/Temporary/flutter-install.sh"

    clear
else
    echo "paru is required to install Flutter."
    read -p "Install it? [Y/n]" response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    if [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]]; then
        /home/$username/Temporary/paru-install.sh
        /home/$username/Temporary/flutter-install.sh
    fi
fi