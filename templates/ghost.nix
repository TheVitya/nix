{ config, ... }:
{
  virtualisation.oci-containers.containers.ghost = {
    image = "docker.io/ghost:5.106.1";
    autoStart = true;
    ports = [ "2368:2368" ];
    environment = {
      database__client = "mysql";
      database__connection__host = "ghost_mysql"; # Matches the database container name
      database__connection__user = "ghost"; # Should match MYSQL_USER
      database__connection__password = "ghostpass";  # Should match MYSQL_PASSWORD
      database__connection__database = "ghost"; # Should match MYSQL_DATABASE
      url = "https://ghost.domain.com"; # CHANGEME should match your domain
    };
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.ghost.rule" = "Host(`ghost.domain.com`)"; # CHANGEME
      "traefik.http.services.ghost.loadbalancer.server.port" = "2368";
      "traefik.http.routers.ghost.entrypoints" = "websecure";
      "traefik.http.routers.ghost.tls.certresolver" = "resolver";
      "traefik.http.routers.ghost.middlewares" = "basic-auth";
      "traefik.http.middlewares.basic-auth.basicAuth.users" = "username:password"; # CHANGEME htpasswd -nbB yourusername yourpassword
    };
  };

  virtualisation.oci-containers.containers.ghost_mysql = {
    image = "docker.io/mysql:8.0";
    autoStart = true;
    environment = {
      MYSQL_ROOT_PASSWORD = "root";         # CHANGEME
      MYSQL_DATABASE = "ghost";                 # CHANGEME
      MYSQL_USER = "ghost";
      MYSQL_PASSWORD = "ghostpass";             # CHANGEME
    };
    volumes = [ "/var/lib/mysql:/var/lib/mysql" ]; # Optional: persistent storage
  };

  services.traefik.staticConfigOptions.networks.ghost = {
    name = "ghost";
    external = true;
  };
}
