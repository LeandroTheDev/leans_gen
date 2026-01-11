#!/bin/sh
echo "Leans Gen V-0.6"
echo "Welcome to Leans Gen, in the next steps you will install a fresh arch linux in your device, please proceed with caution, this installer requires constant internet connection."
read -p "Press enter to continue"

# Usseless to download the scripts you are already connected to the internet dummy
#./Libraries/wifi_connect.sh

read -p "Press enter to continue"

clear # Clear previously messages
lsblk # Show devices available

# Ask the user to input the disk
echo "Type the disk you want it to install, ex: /dev/sda or /dev/nvme0n1"
read -p "/dev/" disk
disk="/dev/$disk"

while true; do
    echo "Select installation type:"
    echo "1) Manual disk creation"
    echo "2) Auto installation (Full Disk Wipe)"
    read -p "Enter your choice [1 or 2]: " choice

    case $choice in
        1)
            if [ -d /sys/firmware/efi ]; then
                echo "You are on UEFI mode, 1 UEFI (300MB) partition and 1 Linux (Full) partition is required for installation"
                read -p "Press enter to continue"

                cfdisk $disk # Manual partitioning
                clear # Clear previously messages
                lsblk # Show devices available

                while true; do
                    read -p "Enter UEFI partition: /dev/" uefi_disk
                    uefi_disk="/dev/$uefi_disk"
                    read -p "Enter Linux partition: /dev/" linux_disk
                    linux_disk="/dev/$linux_disk"

                    if [ -n "$uefi_disk" ] && [ -n "$linux_disk" ]; then
                        mkfs.fat -F32 $uefi_disk
                        mkfs.ext4 $linux_disk

                        mkdir -p /mnt
                        mount $linux_disk /mnt
                        mkdir -p /mnt/boot/EFI
                        mount $uefi_disk /mnt/boot/EFI
                        break
                    else
                        echo "Both partitions must be specified. Please try again."
                    fi
                done
            else
                echo "You are on Legacy BIOS mode, 1 linux partition is required for installation"
                read -p "Press enter to continue"

                cfdisk $disk # Manual partitioning
                clear # Clear previously messages
                lsblk # Show devices available

                while true; do
                    read -p "Enter Linux partition: /dev/" linux_disk
                    linux_disk="/dev/$linux_disk"

                    if [ -n "$linux_disk" ]; then
                        mkfs.ext4 $linux_disk

                        mkdir -p /mnt
                        mount $linux_disk /mnt
                        break
                    else
                        echo "Partition must be specified. Please try again."
                    fi
                done
            fi
            break
            ;;
        2)
            ./Libraries/disk_creation.sh $disk
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            ;;
    esac
done

./Libraries/linux_install.sh

read -p "Arch Linux is Fully installed, press enter to continue: " option

clear

echo "Select OS installation type:"
echo "[1] Full Desktop (KDE and Optional Goodies)"
echo "[2] Server (No IDE and No Goodies)"
echo "[3] Empty (Boot Loader Only)"
echo ""

read -p "Enter your choice: " option

case "$option" in
    1)
        arch-chroot /mnt env INSTALLPARTITION="$disk" bash -c 'sh -c "$(curl -sS https://raw.githubusercontent.com/LeandroTheDev/leans_gen/refs/heads/main/Installation/full.sh)"'
        if [ $? -ne 0 ]; then
            echo "The device installation has failed."
            exit 1
        fi
        ;;
    2)
        arch-chroot /mnt env INSTALLPARTITION="$disk" bash -c 'sh -c "$(curl -sS https://raw.githubusercontent.com/LeandroTheDev/leans_gen/refs/heads/main/Installation/server.sh)"'
        if [ $? -ne 0 ]; then
            echo "The device installation has failed."
            exit 1
        fi
        ;;
    3)
        arch-chroot /mnt env INSTALLPARTITION="$disk" bash -c 'sh -c "$(curl -sS https://raw.githubusercontent.com/LeandroTheDev/leans_gen/refs/heads/main/Installation/empty.sh)"'
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