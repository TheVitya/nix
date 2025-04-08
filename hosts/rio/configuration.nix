{ pkgs, ... }:

# Browse all available options here:
# https://search.nixos.org/options?channel=24.11

{
  imports = [
    # Auto-generated file defining detected hardware (disks, GPU, etc.)
    ./hardware-configuration.nix

    # Network config (like hostname, firewall, static IPs)
    ./networking.nix

    # SSH server setup (OpenSSH, root login, SFTP, etc.)
    ./ssh.nix

    # Additional services (this can be a directory with multiple service modules)
    ./services
  ];

  # Bootloader configuration
  # Enables GRUB (the default bootloader)
  boot.loader.grub.enable = true;
  # Installs GRUB on the primary disk (adjust if using EFI or different disk layout)
  # Needed to boot the system — `/dev/sda` is common for BIOS-based setups
  boot.loader.grub.device = "/dev/sda";

  # Time zone setting
  # Sets the system time zone
  # Ensures logs, clocks, cron jobs use your local time
  time.timeZone = "Europe/Berlin";

  # Language & regional settings
  # Default system language/locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Region-specific formats for date, currency, etc.
  # Keep system language in English, but follow German formats (e.g., € currency, metric units)
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Packages installed globally (for all users)
  # Handy command-line tools available on all terminals and shells
  environment.systemPackages = with pkgs; [
    neovim  # Fast, modern text editor (Vim alternative)
    git     # Version control system
    htop    # Interactive system monitor
  ];

  # Program-specific configuration
  programs = {
    git.enable = true;  # Enables system-wide Git configuration (like `/etc/gitconfig`)
  };

  # This sets the baseline for system configuration and upgrade compatibility
  # Prevents breaking changes to system behavior (like default file paths or service versions)
  system.stateVersion = "24.11"; # 📌 Keep this pinned to when you first installed the system
}
