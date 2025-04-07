{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers.netdata = {
    image = "netdata/netdata";
    autoStart = true;
    ports = [ "19999:19999" ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.netdata.rule" = "Host(`netdata.domain.com`)"; # CHANGEME
      "traefik.http.services.netdata.loadbalancer.server.port" = "19999";
      "traefik.http.routers.netdata.entrypoints" = "websecure";
      "traefik.http.routers.netdata.tls.certresolver" = "resolver";
      "traefik.http.routers.netdata.middlewares" = "basic-auth";
      "traefik.http.middlewares.basic-auth.basicAuth.users" = "username:password"; # CHANGEME htpasswd -nbB yourusername yourpassword
    };
  };

  services.traefik.staticConfigOptions.networks.netdata = {
    name = "netdata";
    external = true;
  };
}
