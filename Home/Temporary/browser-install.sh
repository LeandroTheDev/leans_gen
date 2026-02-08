#!/bin/sh
echo "Installing Browser..."
username=$(whoami)
cd "/home/$username"

echo "Choose a browser:"
echo "1) Firefox"
echo "2) Waterfox"
echo "3) Chromium"
echo "4) None"

read -p "Option: " option

case "$option" in
  1)
    sudo pacman -S firefox
    ;;
  2)
    if [ -x /usr/bin/paru ]; then
        echo ""
        echo "How do you want to install Waterfox?"
        echo "1) Compile from source (recommended, always up-to-date)"
        echo "2) Use prebuilt binary (faster, good for slow computers, may be outdated)"
        read -p "Choose an option [1/2]: " choice

        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [[ "$choice" == "2" || "$choice" == "binary" ]]; then
            paru -Sy waterfox-bin
        elif [[ "$choice" == "1" || "$choice" == "compile" || -z "$choice" ]]; then
            paru -Sy waterfox
        else
            echo "Invalid option. Exiting."
            exit 1
        fi

        # rm -rf "/home/$username/Temporary/browser-install.sh"
        # sudo rm -rf "/etc/skel/Temporary/browser-install.sh"

        clear
    else
        echo "paru is required to install Waterfox."
        read -p "Install it? [Y/n]" response
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
        if [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]]; then
            /home/$username/Temporary/paru-install.sh
            /home/$username/Temporary/browser-install.sh
        fi
    fi
    ;;
  3)
    sudo pacman -S chromium
    ;;
  4)
    ;;
  *)
    echo "Invalid option"
    exit 1
    ;;
esac