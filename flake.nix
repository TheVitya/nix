{
  # Description of the flake (purely metadata, no functional effect)
  description = "Nix config";

  # Input flakes this configuration depends on
  inputs = {
    # Home Manager for managing user environments
    home-manager = {
      url = "github:nix-community/home-manager";
      # Ensures Home Manager uses the same nixpkgs as the rest of the system
      # Helps avoid mismatched package versions between system and user environments
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unstable nixpkgs version for bleeding edge packages
    # Ideal when you want access to the latest packages or kernel improvements
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Stable nixpkgs version, e.g., for more reliable builds
    # Use this when you want reproducibility, stability, or when deploying to production
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    
    # Managing secrets for hosts and users
    agenix.url = "github:ryantm/agenix";

    # Your personal dotfiles repo
    dotfiles = {
      url = "github:TheVitya/.dotfiles/home";
      # Not a flake, just a plain git repo
      # Allows you to pull in personal config files (e.g. `.zshrc`, `.vimrc`) without needing to flake-ify them
      flake = false;
    };
  };

  # Output definitions (what this flake provides)
  outputs = { self, dotfiles, home-manager, agenix, nixpkgs, ... } @ inputs: let
    # Reuse `outputs` inside the config
    inherit (self) outputs;

    # List of supported system architectures
    # Helps you build packages or configs for multiple platforms in CI or for cross-platform development
    systems = [
      "aarch64-linux"     # 64-bit ARM (Linux)
      "i686-linux"        # 32-bit x86 (Linux)
      "x86_64-linux"      # 64-bit x86 (Linux)
      "aarch64-darwin"    # 64-bit ARM (macOS - Apple Silicon)
      "x86_64-darwin"     # 64-bit x86 (macOS - Intel)
    ];

    # Utility function to apply something for all systems
    # Clean and scalable way to generate system-specific attributes like packages or apps
    forAllSystems = nixpkgs.lib.genAttrs systems;

  in {
    # Define packages per system using the ./pkgs directory
    # Expose custom CLI tools or libraries you define in `./pkgs` to be installed via `nix run` or `nix profile install`
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Define overlays using the ./overlays directory
    # Useful for overriding or extending existing packages (e.g., patching a package, changing dependencies)
    overlays = import ./overlays { inherit inputs; };

    # Define NixOS configurations
    # Lets you rebuild your system config with `nixos-rebuild --flake .#rio`
    # Ideal for managing multiple machines declaratively
    nixosConfigurations = {
      # NixOS config for a host named "rio"
      rio = nixpkgs.lib.nixosSystem {
        # Pass extra arguments to the config
        specialArgs = { inherit inputs outputs; };
        # List of configuration modules for this host
        modules = [
          ./hosts/rio
          agenix.nixosModules.default
        ];
      };
    };

    # Define Home Manager configurations
    # Great for per-user dotfile versioning or setting up new machines
    # Manage user-specific settings (e.g., shell config, dev tools) independently of the system config
    homeConfigurations = {
      # Home Manager config for viktornagy on host "rio"
      "viktornagy@rio" = home-manager.lib.homeManagerConfiguration {
        # Use legacy nixpkgs for this system
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        # Extra args available in the configuration
        extraSpecialArgs = { inherit inputs outputs; };
        # List of modules for this user's configuration
        modules = [ ./home/viktornagy/rio.nix ];
      };
    };
  };
}
