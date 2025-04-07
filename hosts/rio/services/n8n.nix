{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers.n8n = {
    image = "docker.n8n.io/n8nio/n8n";
    autoStart = true;
    ports = [ "5678:5678" ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.n8n.rule" = "Host(`n8n.thecodingadventure.com`)";
      "traefik.http.services.n8n.loadbalancer.server.port" = "5678";
      "traefik.http.routers.n8n.entrypoints" = "websecure";
      "traefik.http.routers.n8n.tls.certresolver" = "resolver";
    };
  };

  services.traefik.staticConfigOptions.networks.n8n = {
    name = "n8n";
    external = true;
  };
}
