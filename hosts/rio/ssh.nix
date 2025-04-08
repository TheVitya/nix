{ config, pkgs, ... }:

# Browse all available networking options here:
# https://search.nixos.org/options?channel=24.11&query=services.openssh

{
  services.openssh = {
    # OpenSSH server, allowing remote access via SSH (Secure Shell)
    # Essential for headless servers, remote administration, file transfers, or SSH-based development
    enable = true;

    # Allows logging in as the root user over SSH
    settings.PermitRootLogin = "prohibit-password";

    # SFTP (SSH File Transfer Protocol)
    # Lets users transfer files over SSH using tools like `scp`, `rsync`, or GUI apps like FileZilla
    allowSFTP = true;

    # Disable password login
    settings.PasswordAuthentication = false;

    # Only allow specific users to log in
    # allowUsers = [ "viktornagy" ];
  };
}
