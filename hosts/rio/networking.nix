{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  networking.hostName = "rio";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ]; # SSH + HTTP + HTTPS
    allowedTCPPortRanges = [ ];   # Optional: use this to allow additional ranges
  };

  # If you need a static IP (like for local DNS or port forwarding), set it here:
  # networking.useDHCP = false;
  # networking.interfaces.eth0.ipv4.addresses = [{
  #   address = "192.168.1.100";
  #   prefixLength = 24;
  # }];
}
