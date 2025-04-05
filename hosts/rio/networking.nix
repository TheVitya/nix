{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  networking.hostName = "rio";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 8080 ];

  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [{
    address = "192.168.1.100";
    prefixLength = 24;
  }];
}
