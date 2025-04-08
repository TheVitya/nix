{ config, ... }: {
  imports = [
    ./home.nix
    ./dotfiles

    ../common
  ];
}
