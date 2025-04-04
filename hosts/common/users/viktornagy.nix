{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.viktornagy = {
    initialHashedPassword = "$y$j9T$IoChbWGYRh.rKfmm0G86X0$bYgsWqDRkvX.EBzJTX.Z0RsTlwspADpvEF3QErNyCMC";
    isNormalUser = true;
    description = "viktornagy";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpqUlEzSQKT9z7IM1QNZIogzQQecrFGkUOxltJIfGqGoRrMTPqTkAidoLM9iw9Xsb7JAx2PUk0pVS4SXKO7cNJjv/Ty3eldqJKtHOd6rZiDnRvMunYzR7MjExg/BscR+VUyY0V+dDOC1ljJMAjP/CEXug21OEv9l1gNtxOx+NCJqDJNpkcCweoyBheVuzbOF6pwSWwEa3OYi7llc+g2/Xt89Sx4bfeRavN5lmVyJrR9PXmrE2hSLJP3XxVPhpIkiDNff4aODLZQsaXIKn7J8j2tGLtBN5cWACGrAkyM8RG2L799oUFudRN5LuJ+Cl13qXc7rTbKpnB5+nf9geUHkHr4ebVURLY5s/p03+5F1Ni8ZpSGcj7e1/ZDNrupPek3wFgfqYpq4GKjC90Q0LI/99Pgz9Ple/hy4XYXzrRXlpCD6p70WIY2A63oJkZvG6hAXd/l0jG5H5oZT3ELvMEyX1sKmcscGCFkGhv89XwvkYxXFtIKWWvuJsFseuP7ovpRk0= viktornagy@Viktors-MacBook-Pro.local"
    ];
    packages = [inputs.home-manager.packages.${pkgs.system}.default];
  };
  home-manager.users.viktornagy =
    import ../../../home/viktornagy/${config.networking.hostName}.nix;
}
