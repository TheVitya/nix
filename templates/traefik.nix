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
            email = "email"; # CHANGEME
            storage = "/var/lib/traefik/acme.json";
            tlsChallenge = {};
          };
        };
      };

      providers.docker.endpoint = "unix:///run/docker.sock";

      networks = {
        # CHANGEME
        # ADD HERE NEW NETWORKS
        example = {
          name = "example_default";
          external = true;
        };
      };
    };
  };

  users.groups.podman.members = [ "traefik" ];
}
