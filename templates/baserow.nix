{ config, pkgs, ... }:

{
  virtualisation.oci-containers.containers.baserow = {
    image = "baserow/baserow:1.21.1";
    autoStart = true;
    ports = [ "3000:3000" ]; 
    environment = {
      BASEROW_PUBLIC_URL = "https://baserow.domain.com";
    };
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.baserow.rule" = "Host(`baserow.domain.com`)";
      "traefik.http.services.baserow.loadbalancer.server.port" = "3000";
      "traefik.http.routers.baserow.entrypoints" = "websecure";
      "traefik.http.routers.baserow.tls.certresolver" = "resolver";
      "traefik.http.routers.baserow.middlewares" = "basic-auth";
      "traefik.http.middlewares.basic-auth.basicAuth.users" = "username:password";
    };
  };

  services.traefik.staticConfigOptions.networks.baserow = {
    name = "baserow";
    external = true;
  };
}
