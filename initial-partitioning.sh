#!/usr/bin/env bash
set -euo pipefail

# Set the target disk
disk=/dev/sda

echo "WARNING: This will wipe all data on $disk"
read -rp "Are you sure you want to continue? [y/N] " confirm
[[ "$confirm" == "y" || "$confirm" == "Y" ]] || exit 1

# Unmount if mounted
umount -R /mnt || true
swapoff ${disk}2 || true

# Zap all partition data (MBR + GPT)
sgdisk --zap-all $disk
wipefs -a $disk

# Optionally clear the first few MiB just to be sure
dd if=/dev/zero of=$disk bs=1M count=10 conv=fsync

echo "Disk $disk has been wiped."

# 1. Wipe and create a new GPT partition table
sudo parted --script $disk mklabel gpt

# 2. Create partitions:
#    - 100MiB EFI System Partition
#    - 512MiB Linux Swap
#    - Rest for Linux filesystem (label: nixos)
sudo parted --script $disk mkpart primary fat32 1MiB 101MiB
sudo parted --script $disk set 1 esp on
sudo parted --script $disk mkpart primary linux-swap 101MiB 613MiB
sudo parted --script $disk mkpart primary ext4 613MiB 100%

# 3. Format partitions with appropriate labels
sudo mkfs.fat -F32 -n boot ${disk}1       # EFI System Partition
sudo mkswap -L swap ${disk}2              # Swap Partition
sudo mkfs.ext4 -L nixos ${disk}3          # Root Partition

# 4. Mount root and EFI partitions
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot

# 5. Enable swap
sudo swapon ${disk}2

# 6. Generate NixOS config
sudo nixos-generate-config --root /mnt
