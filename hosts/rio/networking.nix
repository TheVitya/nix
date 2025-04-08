{ config, pkgs, ... }:

# Browse all available networking options here:
# https://search.nixos.org/options?channel=24.11&query=networking

{
  # NetworkManager as the main tool to manage network interfaces (Wi-Fi, Ethernet, VPNs, etc.)
  # Ideal for laptops and desktops where networks change frequently (e.g., Wi-Fi at home/work)
  networking.networkmanager.enable = true;

  # Sets the system's hostname
  # Useful for identification on the network, SSH access, or when configuring a local DNS
  networking.hostName = "rio";

  # Firewall configuration
  networking.firewall = {
    # Enables the built-in NixOS firewall (based on nftables or iptables)
    enable = true;

    # Opens ports:
    #   22 - SSH (for remote terminal access)
    #   80 - HTTP (for web server or dev testing)
    #   443 - HTTPS (secure web traffic)
    allowedTCPPorts = [ 80 443 22 ];

    # Leave empty unless you want to allow a full range, like [ { from = 3000; to = 3010; } ]
    # e.g., for game servers, dev environments like Vite/React that use random ports, etc.
    allowedTCPPortRanges = [ ];
  };

  # Set a static IP manually (disabled by default)
  # Required for port forwarding, local DNS resolution, or home servers
  # networking.useDHCP = false;
  # networking.interfaces.eth0.ipv4.addresses = [{
  #   address = "192.168.1.100";  # Desired static IP
  #   prefixLength = 24;          # Subnet mask (255.255.255.0)
  # }];
}
