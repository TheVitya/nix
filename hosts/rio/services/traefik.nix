{ config, pkgs, ... }: {
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      log = { level = "INFO"; };

      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
        };
      };

      certificatesResolvers = {
        resolver = {
          acme = {
            email = "vktrnagy64@gmail.com";
            storage = "/var/lib/traefik/acme.json";
            tlsChallenge = {};
          };
        };
      };

      providers.docker.endpoint = "unix:///run/docker.sock";

      networks = {
        blog = {
          name = "blog_default";
          external = true;
        };
      };
    };
  };

  users.groups.podman.members = [ "traefik" ];
}
