#!/bin/bash
if [ ! -d /sys/firmware/efi ]; then
    if [ -z "$INSTALLPARTITION" ]; then
        echo "You need to set the INSTALLPARTITION variable for Legacy BIOS."
        echo "Try: export INSTALLPARTITION=/dev/sdX before running this script"
        exit 1
    fi
elif ! mountpoint -q /boot/EFI; then
    echo "You need to mount the EFI partition for UEFI BIOS."
    exit 1
fi

### REGION: Timezone set
while true; do
    echo "Select your timezone:"
    echo "1) America/Sao_Paulo 🇧🇷"
    echo "2) America/New_York 🇺🇸"
    echo "3) America/Los_Angeles 🇺🇸"
    echo "4) Europe/London 🇬🇧"
    echo "5) Europe/Berlin 🇩🇪"
    echo "6) Europe/Paris 🇫🇷"
    echo "7) Europe/Moscow 🇷🇺"
    echo "8) Asia/Shanghai 🇨🇳"
    echo "9) Asia/Tokyo 🇯🇵"
    echo "0) Cancel"

    read -p "Enter the number of your choice: " choice

    case $choice in
        1) timezone="America/Sao_Paulo" ;;
        2) timezone="America/New_York" ;;
        3) timezone="America/Los_Angeles" ;;
        4) timezone="Europe/London" ;;
        5) timezone="Europe/Berlin" ;;
        6) timezone="Europe/Paris" ;;
        7) timezone="Europe/Moscow" ;;
        8) timezone="Asia/Shanghai" ;;
        9) timezone="Asia/Tokyo" ;;
        0) echo "Canceled."; exit 0 ;;
        *) echo "Invalid option. Try again." && continue ;;
    esac

    echo "Setting timezone to: $timezone"
    timedatectl set-timezone "$timezone"
    echo "Timezone configured:"
    timedatectl status
    hwclock --systohc
    break
done
### ENDREGION

clear
while true; do
    echo "System Language"
    echo "1 - English"
    read -p "Select an option: " choice
    
    case $choice in
        1)
            sed -i '/#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
            break
            ;;
        2)
            echo "Not added yet"
            #break
            ;;
        *)
            echo "Invalid option. Please select between the avalaible options"
            ;;
    esac
done
locale-gen

clear

read -p "Device name: " deviceName
echo "$deviceName" | tee /etc/hostname > /dev/null
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $deviceName.localdomain $deviceName
EOF

### REGION: Root and Administrator creation
while true; do
    echo "Type the root password:"
    passwd
    if [ $? -eq 0 ]; then
        break
    else
        echo "Failed to set root password. Try again."
    fi
done
### ENDREGION

clear

# Installation Confirmation
echo "The bootloader will be installed now in $INSTALLPARTITION"
read -p "Do you want to proceed? (Y/n): " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
if [[ "$response" == "n" || "$response" == "no" ]]; then
    echo "Aborted"
    exit 1
fi

if [ -d /sys/firmware/efi ]; then
    echo "UEFI Detected, Installing UEFI boot loader"
    pacman -S grub efibootmgr dosfstools os-prober mtools ntfs-3g --noconfirm

    grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=LeansGen --recheck
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "Legacy (BIOS), Creating one single signature for Linux partition"
    pacman -S grub dosfstools os-prober mtools ntfs-3g --noconfirm
    grub-install "${INSTALLPARTITION}"
fi

tee /usr/sbin/update-grub > /dev/null << 'EOF'
#!/bin/sh
set -e
exec grub-mkconfig -o /boot/grub/grub.cfg "$@"
EOF

chown root:root /usr/sbin/update-grub
chmod 755 /usr/sbin/update-grub

pacman -S networkmanager --noconfirm
systemctl enable NetworkManager

clear

update-grub

exit