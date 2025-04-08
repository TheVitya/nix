# Common configuration for all hosts

{
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Custom user configs
    ./users

    # Enables Home Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    # Makes `home.packages` available system-wide via user profile
    useUserPackages = true;
    # Pass flake inputs/outputs into modules for easier access
    # You can use `inputs.<name>` and `outputs.<name>` directly in user configs
    extraSpecialArgs = { inherit inputs outputs; };
  };

  nixpkgs = {
    # Add your overlays here to customize or extend packages
    overlays = [
      # From your flake's own overlays
      outputs.overlays.additions          # New packages
      outputs.overlays.modifications      # Modifications to existing packages
      outputs.overlays.stable-packages    # Pinned stable versions of packages

      # Add overlays from external flakes
      # neovim-nightly-overlay.overlays.default

      # You can also define one inline:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    # Configuration of nixpkgs
    config = {
      # Allow non-free software like NVIDIA drivers, VSCode, etc.
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      # Enables modern features: `nix flake` and `nix profile`
      experimental-features = "nix-command flakes";

      # Users allowed to perform privileged Nix actions (e.g., build/store access)
      trusted-users = [
        "root"
        "viktornagy"
      ];
    };

    # Garbage collection: clean up unused packages
    gc = {
      # Runs GC periodically
      automatic = true;
      # Deletes packages unused for 30+ days
      # Use case: Saves disk space without breaking current setups
      options = "--delete-older-than 30d";
    };

    # Deduplicates Nix store to save space
    optimise.automatic = true;

    # Automatically create a registry mapping flake inputs (makes `nix run <name>` work)
    registry = (lib.mapAttrs (_: flake: { inherit flake; }))
      ((lib.filterAttrs (_: lib.isType "flake")) inputs);

    # Fallback path for legacy nix commands
    # Compatibility with older tools or scripts using `NIX_PATH`
    nixPath = [ "/etc/nix" ];
  };
}
