{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.viktornagy = {
    # Password configuration
    # Plaintext password — avoid in production!
    # password = "vitya";

    # SHA-512 hashed password (recommended) — you can generate with `mkpasswd -m sha-512`
    hashedPassword = "$6$WaQff5zXiX2lDWd4$FLVn3xYBDMr/4IOvDxPkRfrh9zHlo2KLcZFnlZGfiHc6CM7rWAQGD/F2E3fAKZCarIa/0Rcd6LWoHjwJRWlw10";

    # Marks as a regular user (not a system service user)
    isNormalUser = true;

    # Display name
    description = "viktornagy";

    # These enable system-level privileges related to system hardware, virtualization, and media
    extraGroups = [
      "wheel"             # Sudo access
      "networkmanager"    # Control networking (e.g., via `nmcli`)
    ];

    # Public SSH key to allow login without a password (useful for headless systems)
    # Enables passwordless SSH login for this user
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpqUlEzSQKT9z7IM1QNZIogzQQecrFGkUOxltJIfGqGoRrMTPqTkAidoLM9iw9Xsb7JAx2PUk0pVS4SXKO7cNJjv/Ty3eldqJKtHOd6rZiDnRvMunYzR7MjExg/BscR+VUyY0V+dDOC1ljJMAjP/CEXug21OEv9l1gNtxOx+NCJqDJNpkcCweoyBheVuzbOF6pwSWwEa3OYi7llc+g2/Xt89Sx4bfeRavN5lmVyJrR9PXmrE2hSLJP3XxVPhpIkiDNff4aODLZQsaXIKn7J8j2tGLtBN5cWACGrAkyM8RG2L799oUFudRN5LuJ+Cl13qXc7rTbKpnB5+nf9geUHkHr4ebVURLY5s/p03+5F1Ni8ZpSGcj7e1/ZDNrupPek3wFgfqYpq4GKjC90Q0LI/99Pgz9Ple/hy4XYXzrRXlpCD6p70WIY2A63oJkZvG6hAXd/l0jG5H5oZT3ELvMEyX1sKmcscGCFkGhv89XwvkYxXFtIKWWvuJsFseuP7ovpRk0="
    ];

    # Installs Home Manager's default CLI tool (`home-manager`) into the user environment
    packages = [
      inputs.home-manager.packages.${pkgs.system}.default
    ];
  };

  # Loads the Home Manager config for viktornagy based on the machine's hostname
  # Makes it easy to reuse user configs across multiple hosts (e.g., "rio.nix", "workstation.nix")
  home-manager.users.viktornagy =
    import ../../../home/viktornagy/${config.networking.hostName}.nix;
}
