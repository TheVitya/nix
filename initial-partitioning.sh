#!/bin/bash
set -euo pipefail

# 🧱 Set the target disk
disk=/dev/sda

# ⚠️ Prompt the user to confirm before wiping the disk
echo "⚠️  WARNING: This will wipe all data on $disk"
read -r -p "Are you sure you want to continue? Type 'yes' to proceed: " confirm < /dev/tty
confirm="${confirm:-}"
if [[ "$confirm" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

# 🔌 Unmount anything already mounted at /mnt and disable swap
umount -R /mnt || true
swapoff "${disk}2" || true

# 💣 Completely erase all partition data (MBR + GPT)
sgdisk --zap-all "$disk"
wipefs -a "$disk"

# 🧼 Zero out the first 10MiB for good measure
dd if=/dev/zero of="$disk" bs=1M count=10 conv=fsync

echo "✅ Disk $disk has been wiped."

# 📐 Create new GPT partition table and define three partitions:
#   1. EFI System Partition (100MiB)
#   2. Linux swap (512MiB)
#   3. Root ext4 partition (remaining space)
parted -s "$disk" \
  mklabel gpt \
  mkpart ESP fat32 1MiB 101MiB \
  set 1 esp on \
  mkpart primary linux-swap 101MiB 613MiB \
  mkpart primary ext4 613MiB 100%

# 🕒 Wait briefly for the kernel to register new partitions
sleep 2

# 🏗️ Format the new partitions with appropriate labels and filesystems
mkfs.fat -F32 -n boot "${disk}1"    # EFI partition (vfat)
mkswap -L swap "${disk}2"           # Swap partition
mkfs.ext4 -L nixos "${disk}3"       # Root partition

# 📦 Mount partitions for NixOS installation
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon "${disk}2"

# 🛠️ Generate the initial NixOS config files in /mnt/etc/nixos
nixos-generate-config --root /mnt

# 📝 Patch the config to make the system bootable by specifying the GRUB device
CONFIG_FILE="/mnt/etc/nixos/configuration.nix"

# Delete trailing `}` from `configuration.nix` so that we can append more to it.
sed -i -E 's:^\}\s*$::g' $CONFIG_FILE
sed -i '/boot\.loader\.grub\.enable = true;/d' $CONFIG_FILE

# Extend/override default `configuration.nix`:
echo '
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    # Replace this by your SSH pubkey!
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpqUlEzSQKT9z7IM1QNZIogzQQecrFGkUOxltJIfGqGoRrMTPqTkAidoLM9iw9Xsb7JAx2PUk0pVS4SXKO7cNJjv/Ty3eldqJKtHOd6rZiDnRvMunYzR7MjExg/BscR+VUyY0V+dDOC1ljJMAjP/CEXug21OEv9l1gNtxOx+NCJqDJNpkcCweoyBheVuzbOF6pwSWwEa3OYi7llc+g2/Xt89Sx4bfeRavN5lmVyJrR9PXmrE2hSLJP3XxVPhpIkiDNff4aODLZQsaXIKn7J8j2tGLtBN5cWACGrAkyM8RG2L799oUFudRN5LuJ+Cl13qXc7rTbKpnB5+nf9geUHkHr4ebVURLY5s/p03+5F1Ni8ZpSGcj7e1/ZDNrupPek3wFgfqYpq4GKjC90Q0LI/99Pgz9Ple/hy4XYXzrRXlpCD6p70WIY2A63oJkZvG6hAXd/l0jG5H5oZT3ELvMEyX1sKmcscGCFkGhv89XwvkYxXFtIKWWvuJsFseuP7ovpRk0= viktornagy@Viktors-MacBook-Pro.local"
  ];
}
' >> $CONFIG_FILE

echo "🎉 Disk is partitioned, mounted, and ready for installation!"
echo "🎉 Installing..."

nixos-install --no-root-passwd

# poweroff
