#!/bin/sh
clear

if ! mount | grep -q 'on /mnt '; then
    echo "There is no partition mounted in /mnt, you need to mount your system before executing the script, if you are trying execute this script manually without the installer script is because you missed something after the disk signatures, refer the disk_creation.sh in the github installation folder"
    exit 1
fi

# Installation Confirmation
echo "Install linux in the mounted device /mnt?"
read -p "Do you want to proceed? (Y/n): " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
if [[ "$response" == "n" || "$response" == "no" ]]; then
    echo "Aborted"
    exit 1
fi

# ---------- Firmware Selection ----------
FIRMWARE_PACKAGES=""

add_pkg() {
    case " $FIRMWARE_PACKAGES " in
        *" $1 "*) ;; # already added
        *) FIRMWARE_PACKAGES="$FIRMWARE_PACKAGES $1" ;;
    esac
}

while true; do
    echo
    echo "Select firmware to install:"
    echo "1 - All firmware (full linux-firmware), recommended!"
    echo "2 - Intel (WiFi, Bluetooth, iGPU, etc)"
    echo "3 - NVIDIA GPUs"
    echo "4 - AMD GPUs"
    echo "5 - Network / Bluetooth vendors (Realtek, Atheros, Broadcom, MediaTek)"
    echo "6 - Extra Firmwares / Sound Open Firmware"
    echo "0 - Done selecting"
    echo

    read -p "Option: " opt

    case "$opt" in
        1) add_pkg "linux-firmware" ;;
        2) add_pkg "linux-firmware-intel" ;;
        3) add_pkg "linux-firmware-nvidia" ;;
        4) 
            add_pkg "linux-firmware-amdgpu"
            add_pkg "linux-firmware-radeon"
            ;;
        5)
            add_pkg "linux-firmware-realtek"
            add_pkg "linux-firmware-atheros"
            add_pkg "linux-firmware-broadcom"
            add_pkg "linux-firmware-mediatek"
            ;;
        6)
            add_pkg "sof-firmware" ;;
        0) break ;;
        *) echo "Invalid option" ;;
    esac
done

echo
echo "Selected firmware packages:$FIRMWARE_PACKAGES"
echo

# Installation Process
pacstrap /mnt base base-devel linux $FIRMWARE_PACKAGES vim

# Generating fstab for the Linux System
genfstab -U /mnt >> /mnt/etc/fstab