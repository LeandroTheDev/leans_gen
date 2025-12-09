#!/bin/sh
echo "Leans Gen V-0.5"
echo "Welcome to Leans Gen, in the next steps you will install a fresh arch linux in your device, please proceed with caution, this installer requires constant internet connection."
read -p "Press enter to continue"

./Libraries/wifi_connect.sh

read -p "Press enter to continue"

clear # Clear previously messages
lsblk # Show devices available

# Ask the user to input the disk
echo "Type the disk you want it to install, ex: /dev/sda or /dev/nvme0n1"
read -p "/dev/" disk
disk="/dev/$disk"

./Libraries/disk_creation.sh $disk

./Libraries/linux_install.sh $disk

clear

echo "Select installation type:"
echo "[1] Full Desktop"
echo "[2] Server"
echo "[3] Empty"
echo ""

read -p "Enter your choice: " option

case "$option" in
    1)
        arch-chroot /mnt bash -c 'export INSTALLPARTITION="$disk" && sh -c "$(curl -sS https://raw.githubusercontent.com/LeandroTheDev/arch_linux/refs/heads/leansgen/Installation/full.sh)"'
        if [ $? -ne 0 ]; then
            echo "The device installation has failed."
            exit 1
        fi
        ;;
    2)
        arch-chroot /mnt bash -c 'export INSTALLPARTITION="$disk" && sh -c "$(curl -sS https://raw.githubusercontent.com/LeandroTheDev/arch_linux/refs/heads/leansgen/Installation/server.sh)"'
        if [ $? -ne 0 ]; then
            echo "The device installation has failed."
            exit 1
        fi
        ;;
    3)
        arch-chroot /mnt bash -c 'export INSTALLPARTITION="$disk" && sh -c "$(curl -sS https://raw.githubusercontent.com/LeandroTheDev/arch_linux/refs/heads/leansgen/Installation/empty.sh)"'
        if [ $? -ne 0 ]; then
            echo "The device installation has failed."
            exit 1
        fi
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

clear

umount -R -l /mnt

echo "Device configurations has been a success, the system will reboot now, press any key to reboot GLHF"
read -n 1 -s
reboot