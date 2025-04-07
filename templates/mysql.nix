{ config, ... }:
{
  virtualisation.oci-containers.containers.mysql = {
    image = "docker.io/mysql:8.0";
    autoStart = true;
    environment = {
      MYSQL_ROOT_PASSWORD = "root";         # CHANGEME
      MYSQL_DATABASE = "mysql";                 # CHANGEME
      MYSQL_USER = "mysql";
      MYSQL_PASSWORD = "mysql";             # CHANGEME
    };
    volumes = [ "/var/lib/mysql:/var/lib/mysql" ]; # Optional: persistent storage
  };
}
