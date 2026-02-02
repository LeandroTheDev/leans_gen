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

### REGION: Personal OS for LeansGEN
echo "Downloading system template..."
pacman -S git --noconfirm
git clone https://github.com/LeandroTheDev/leans_gen.git /tmp/leans_gen
cp -r /tmp/leans_gen/Home/{.,}* /etc/skel
chmod 755 -R /etc/skel
rm -rf /tmp/leans_gen
chmod +x /etc/skel/Temporary/*

# After template installation, lets copy the root template
cp -r /etc/skel/.root/. /
# Remove the temporary .root folder
rm -rf /etc/skel/.root
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

while true; do
    read -p "Administrator username: " username

    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Choose another name."
        continue
    fi

    useradd -m "$username"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Failed to create user. Try again."
    fi
done

while true; do
    echo "Type the password for user '$username':"
    passwd "$username"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Failed to set user password. Try again."
    fi
done
### ENDREGION

usermod -aG wheel $username
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

clear

### REGION: Boot Loader
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
### ENDREGION

# Install and enable network manager for internet usage
pacman -S networkmanager --noconfirm
systemctl enable NetworkManager

# Enable multilibraries packages from arch linux repository
sed -i 's/^#\[\(multilib\)\]/[\1]/' /etc/pacman.conf
sed -i '/^\[multilib\]/ {n; s/^#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/}' /etc/pacman.conf
pacman -Sy

clear

### REGION: Personal OS for LeansGEN
# Installing the OS
pacman -S plasma-desktop sddm konsole dolphin kscreen kde-gtk-config pipewire pipewire-jack pipewire-pulse pipewire-alsa wireplumber plasma-pa breeze-gtk bluedevil plasma-nm
systemctl enable sddm

clear
### ENDREGION

clear

# System Drivers
while true; do
    echo "CPU Drivers"
    echo "1 - Intel"
    echo "2 - AMD"
    echo "3 - Virtual Machine"
    echo "4 - Exit"
    read -p "Select an option: " choice

    case $choice in
        1)
            pacman -S intel-ucode --noconfirm
            break
            ;;
        2)
            pacman -S amd-ucode --noconfirm
            break
            ;;
        3)
            break
            ;;
        4)
            break
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            ;;
    esac
done
while true; do
    echo "Graphics Drivers, if you have Hybrid GPUs consider installing for both"
    echo "1 - Intel"
    echo "2 - Nvidia"
    echo "3 - AMD"
    echo "4 - Virtual Machine"
    echo "5 - Exit"
    read -p "Select an option: " choice
    
    case $choice in
        1)
            pacman -S vulkan-intel lib32-vulkan-intel linux-headers --noconfirm
            ;;
        2)
            pacman -S nvidia nvidia-utils lib32-nvidia-utils libva-nvidia-driver linux-headers --noconfirm
            ;;
        3)
            pacman -S vulkan-radeon lib32-vulkan-radeon linux-headers --noconfirm
            ;;
        4)
            # Instal virtual box dependencies
            pacman -S virtualbox-guest-utils --noconfirm
            systemctl enable vboxservice.service

            # Add user to the virtual machine group
            usermod -aG vboxsf "$username"
            break
            ;;
        5)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            ;;
    esac
done

### REGION: Personal OS for LeansGEN
while true; do
    echo "LeansGEN Goddies"
    echo "1 - Basic Desktop (Waterfox, Kwrite Gwenview, GIMP, Paru, Flameshot, Ark and Compress Tools, Plasma System Monitor, VLC, Qbittorrent)"
    echo "2 - Social (Vesktop - Custom Discord)"
    echo "3 - Streaming (OBS Studio)"
    echo "4 - Gaming (Steam, Mangohud, Goverlay, Gamemode)"
    echo "5 - Development (Flutter, .NET, Rust, VSCode, OpenSSH, Chromium, DBeaver)"
    echo "6 - Bluetooth Drivers"
    echo "7 - Exit"
    read -p "Select an option: " choice
    
    case $choice in
        1)
            pacman -S kwrite gwenview gimp ark unzip zip unrar p7zip flameshot plasma-systemmonitor vlc qbittorrent

            su $username -c "/home/$username/Temporary/paru-install.sh"
            su $username -c "/home/$username/Temporary/waterfox-install.sh"
            ;;
        2)
            su $username -c "/home/$username/Temporary/vesktop-install.sh"
            ;;
        3)
            su $username -c "/home/$username/Temporary/obs-install.sh"
            ;;
        4)
            pacman -S steam mangohud goverlay gamemode
            ;;
        5)
            pacman -S vscode dotnet-sdk dotnet-runtime chromium rustup openssh dbeaver
            su $username -c "rustup default stable"
            su $username -c "/home/$username/Temporary/flutter-install.sh"
            ;;
        6)
            pacman -S bluez bluez-utils
            systemctl enable bluetooth

            su $username -c "/home/$username/Temporary/xbox-bluetooth-drivers.sh"
            ;;
        7)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            ;;
    esac
done

### ENDREGION

# Numlock on boot
chmod +x /usr/local/bin/numlock
systemctl enable numlock

echo "Do you wish to auto mount any external device on starting the system?"
read -p "Do you want to accept? (Y/n): " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
if [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]]; then
    chmod +x "/home/$username/Temporary/generate-mount.sh"
    su $username -c "/home/$username/Temporary/generate-mount.sh"
else
    rm -rf "/home/$username/Temporary/generate-mount.sh"
    rm -rf "/etc/skel/Temporary/generate-mount.sh"
fi

# Swap memory creation
while true; do
    echo "How much GB do you want for swap memory? (0 = no swap)"
    read swap_size_gb

    case "$swap_size_gb" in
        ''|*[!0-9]*)
            echo "Please enter a valid non-negative number."
            ;;
        *)
            break
            ;;
    esac
done

if [ "$swap_size_gb" -eq 0 ]; then
    echo "Skipping swap creation."
else
    echo "Creating ${swap_size_gb}G swap file..."

    fallocate -l ${swap_size_gb}G /swapfile || dd if=/dev/zero of=/swapfile bs=1G count=$swap_size_gb
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap defaults 0 0' >> /etc/fstab
fi

# Windows dual boot
echo "Do you wish to enable windows finding in grub?"
read -p "Do you want to accept? (Y/n): " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
if [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]]; then
    sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
fi

# Prevent wrong permissions after installation
chown -R "$username:$username" "/home/$username"

update-grub

exit
