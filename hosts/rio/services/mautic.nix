{ config, lib, pkgs, ... }:

let

### Project Settings
PROJECT_NAME = "mautic";
PROJECT_BASE_URL = "${PROJECT_NAME}.thecodingadventure.com";

MAUTIC_DIR = "/home/mautic";
WORKDIR = "/var/www/html";

DB_NAME = "mautic";
DB_USER = "mautic";
DB_PASSWORD = "mautic";
DB_ROOT_PASSWORD = "password";

### Container Images
MARIADB_TAG = "docker.io/wodby/mariadb:11.4";
MAUTIC_APACHE_TAG = "docker.io/mautic/mautic:5.2.3-apache";

in {
  services.traefik.staticConfigOptions.networks."${PROJECT_NAME}_php" = {
    name = "${PROJECT_NAME}_php";
    external = true;
  };

  virtualisation.oci-containers.containers."${PROJECT_NAME}_php" = {
    image = MAUTIC_APACHE_TAG;
    autoStart = true;
    environment = {
      MAUTIC_DB_HOST = "${PROJECT_NAME}_db";
      MAUTIC_DB_NAME = DB_NAME;
      MAUTIC_DB_USER = DB_USER;
      MAUTIC_DB_PASSWORD = DB_PASSWORD;
    };
    volumes = [
      "${MAUTIC_DIR}/config:${WORKDIR}/config:z"
      "${MAUTIC_DIR}/logs:${WORKDIR}/var/logs:z"
      "${MAUTIC_DIR}/media/files:${WORKDIR}/docroot/media/images:z"
    ];
    dependsOn = [ "${PROJECT_NAME}_db" ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.${PROJECT_NAME}.rule" = "Host(`${PROJECT_BASE_URL}`)";
      "traefik.http.routers.${PROJECT_NAME}.entrypoints" = "websecure";
      "traefik.http.routers.${PROJECT_NAME}.tls.certresolver" = "resolver";
      "traefik.http.routers.${PROJECT_NAME}.middlewares" = "basic-auth";
      "traefik.http.middlewares.basic-auth.basicAuth.users" = "viktornagy:$2y$05$xSKePZRNVrtzakPaymbS/.JGsdM.smlY8ebovK6s6rE2a/HM5rkWu";
    };
  };

  virtualisation.oci-containers.containers."${PROJECT_NAME}_db" = {
    image = MARIADB_TAG;
    autoStart = true;
    environment = {
      MYSQL_INNODB_DATA_FILE_PATH = "ibdata1:10M:autoextend:max:10G";
      MYSQL_GENERAL_LOG = "0";
      MYSQL_ROOT_PASSWORD = DB_ROOT_PASSWORD;
      MYSQL_DATABASE = DB_NAME;
      MYSQL_USER = DB_USER;
      MYSQL_PASSWORD = DB_PASSWORD;
    };
    volumes = [ "${MAUTIC_DIR}/data:/var/lib/mysql" ];
  };

  systemd.services."update-${PROJECT_NAME}" = {
    description = "Create ${PROJECT_NAME} folder structure";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/bash -eu -c 'mkdir -p \"${MAUTIC_DIR}/config\" \"${MAUTIC_DIR}/logs\" \"${MAUTIC_DIR}/media/files\" \"${MAUTIC_DIR}/data\"'";
    };
  };
}
