#!/bin/sh
disk="$1"

# Checking if the user input exist
if [ ! -e "$disk" ]; then
    echo "$disk does not exist"
    exit 1
fi

# Necessary dependencie
pacman -Sy lsof --noconfirm

#  Checking if is mounted somewhere
if mount | grep -q "/dev/$disk"; then
    echo "Disk $disk is currently mounted and in use, try using: umount -R $disk"
    exit 1
# Checking if is currently in use    
elif lsof | grep -q $disk; then
    echo "Disk $disk is being used by some processes."
    exit 1
fi

# Installation Confirmation
clear
echo "Are you sure you want to install in "$disk" all contents inside this drive will be deleted"
read -p "Do you want to proceed? (y/N): " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
if [[ "$response" != "y" && "$response" != "yes" ]]; then
    echo "Aborted"
    exit 1
fi

# Necessary dependencie
pacman -Sy util-linux --noconfirm

# Erase data before using fdisk to prevent unwanted messages
echo "Erasing data..."
wipefs -a -f "$disk"
dd if=/dev/zero of=$disk bs=1M count=1000 status=progress

# Disk formatting
if [ -d /sys/firmware/efi ]; then
    echo "UEFI Detected, Creating 2 partitions EFI and Linux"
    fdisk "$disk" <<EOF
g
n


+300M
t
1
n



w
EOF
else
    echo "Legacy (BIOS), Creating one single Linux partition"
    fdisk "$disk" <<EOF
g
n



w
EOF
fi

# Checking if the fdisk exit sucessfully
if [ $? -eq 0 ]; then
    echo "Success executing the disk partitioning"
else
    echo "Something went wrong..."
    exit 1
fi
output=$(lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT "$disk" | grep -E "part")
partition_count=$(echo "$output" | wc -l)

echo "Creating signatures..."

if [ -d /sys/firmware/efi ]; then
    echo "UEFI Detected, Creating signatures for EFI and Linux partition"

    # Checking partition count
    if [[ $partition_count -ne 2 ]]; then
        echo "Something went wrong, the device has not been correctly partitioned"
        exit 1
    fi

    # Disk signatures
    if [[ $disk == /dev/nvme* ]]; then
        mkfs.fat -F32 "${disk}p1"
        mkfs.ext4 "${disk}p2"
        mount "${disk}p2" /mnt
    elif [[ $disk == /dev/sd* ]]; then
        mkfs.fat -F32 "${disk}1"
        mkfs.ext4 "${disk}2"
        mount "${disk}2" /mnt
    else
        echo "Cannot proceed the signature the device is unkown, only supports nvme and sata/ssd disk"
        exit 1
    fi
else
    echo "Legacy (BIOS), Creating one single signature for Linux partition"

    # Checking partition count
    if [[ $partition_count -ne 1 ]]; then
        echo "Something went wrong, the device has not been correctly partitioned"
        exit 1
    fi

    # Disk signatures
    if [[ $disk == /dev/nvme* ]]; then        
        mkfs.ext4 "${disk}p1"
        mount "${disk}p1" /mnt
    elif [[ $disk == /dev/sd* ]]; then
        mkfs.ext4 "${disk}1"
        mount "${disk}1" /mnt
    else
        echo "Cannot proceed the signature the device is unkown, only supports nvme and sata/ssd disk"
        exit 1
    fi
fi

echo "Disk setup is complete, mounted the ext4 in /mnt"