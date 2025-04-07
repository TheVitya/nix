## Default flake commands

nix flake check
nix flake update
nix flake show
nixos-rebuild switch

## Hetzner setup

mount the iso image
restart the server
open console >\_
sudo su

call curl -sL https://raw.githubusercontent.com/TheVitya/nix/main/init-server.sh | bash
nixos-install
poweroff
unmount iso image
start

download hardware-config from server

## Set ssh config for the server

## Set password for your users

mkpasswd -m sha-512 PASSWORD

## Copy the config to the server

rsync -av --exclude-from='rsync-exclude.txt' . hetzner:/etc/nixos/

## Connect to the server and run build

nixos-rebuild switch

## Traefik

create folder /etc/nixos/traefik-dynamic
