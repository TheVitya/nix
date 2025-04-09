{ config, lib, pkgs, ... }:

let

### Project Settings
PROJECT_NAME = "wordpress";
PROJECT_BASE_URL = "${PROJECT_NAME}.thecodingadventure.com";

WP_DIR = "/home/wordpress";
WP_REPO = "https://github.com/TheVitya/wordpress.git";
WORKDIR = "/var/www/html";
ENV_FILE = ".env.prod";

DB_NAME = "wordpress";
DB_USER = "wordpress";
DB_PASSWORD = "wordpress";
DB_ROOT_PASSWORD = "password";

### Container Images
MARIADB_TAG = "docker.io/wodby/mariadb:11.4";
WORDPRESS_TAG = "docker.io/wodby/wordpress-php:8.3";
NGINX_TAG = "docker.io/wodby/nginx:1.25-5.33.4";

in {
  services.traefik.staticConfigOptions.networks."${PROJECT_NAME}_nginx" = {
    name = "${PROJECT_NAME}_nginx";
    external = true;
  };

  virtualisation.oci-containers.containers."${PROJECT_NAME}_nginx" = {
    image = NGINX_TAG;
    autoStart = true;
    environment = {
      NGINX_STATIC_OPEN_FILE_CACHE = "off";
      NGINX_ERROR_LOG_LEVEL = "debug";
      NGINX_BACKEND_HOST = "${PROJECT_NAME}_php";
      NGINX_VHOST_PRESET = "wordpress";
      NGINX_SERVER_ROOT = WORKDIR;
      NGINX_SERVER_EXTRA_CONF_FILEPATH = "sitemap.conf";
    };
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.${PROJECT_NAME}.rule" = "Host(`${PROJECT_BASE_URL}`)";
      "traefik.http.routers.${PROJECT_NAME}.entrypoints" = "websecure";
      "traefik.http.routers.${PROJECT_NAME}.tls.certresolver" = "resolver";
    };
    volumes = [
      "${WP_DIR}:${WORKDIR}"
      "${WP_DIR}/sitemap.conf:/etc/nginx/sitemap.conf"
    ];
    dependsOn = [ "${PROJECT_NAME}_php" ];
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
    volumes = [ "${WP_DIR}/data:/var/lib/mysql" ];
  };

  virtualisation.oci-containers.containers."${PROJECT_NAME}_php" = {
    image = WORDPRESS_TAG;
    autoStart = true;
    environment = {
      PHP_FPM_CLEAR_ENV = "no";
      ENV_FILE = ENV_FILE;

      PHP_MAIL_MIXED_LF_AND_CRLF = "On";
      PHP_SENDMAIL_PATH = "/usr/bin/msmtp -t";
      MSMTP_HOST = "opensmtpd";
      MSMTP_PORT = "25";

      # PHP_MEMORY_LIMIT = "256M";
      PHP_FPM_PM = "dynamic"; # or "ondemand" for very low traffic sites
      PHP_FPM_PM_MAX_CHILDREN = "3";
      PHP_FPM_PM_START_SERVERS = "2";
      PHP_FPM_PM_MIN_SPARE_SERVERS = "1";
      PHP_FPM_PM_MAX_SPARE_SERVERS = "2";
      PHP_FPM_PM_MAX_REQUESTS = "500";

      DB_HOST = "${PROJECT_NAME}_db";
      DB_USER = DB_USER;
      DB_PASSWORD = DB_PASSWORD;
      DB_NAME = DB_NAME;
      PHP_FPM_USER = "wodby";
      PHP_FPM_GROUP = "wodby";
    };
    volumes = [ "${WP_DIR}:${WORKDIR}" ];
    cmd = [ "sh" "-c" "composer install && php-fpm" ];
    dependsOn = [ "${PROJECT_NAME}_db" ];
  };

  systemd.services."update-${PROJECT_NAME}" = {
    description = "Clone and update ${PROJECT_NAME} repo";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = { "HOME" = "/root"; };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/bash -eu -c 'mkdir -p ${WP_DIR}/data; GIT=/run/current-system/sw/bin/git; echo Setting safe.directory for Git...; $GIT config --global --add safe.directory \"${WP_DIR}\"; if [ -d \"${WP_DIR}/.git\" ]; then echo Pulling latest changes...; $GIT -C \"${WP_DIR}\" pull origin main; else echo Cloning from ${WP_REPO}...; $GIT clone ${WP_REPO} \"${WP_DIR}\"; fi'";
    };
  };

  systemd.timers."update-${PROJECT_NAME}-timer" = {
    description = "Periodic ${PROJECT_NAME} repo update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "15min";
      Unit = "update-${PROJECT_NAME}.service";
    };
  };

  systemd.services."docker-${PROJECT_NAME}_db" = {
    after = [ "update-${PROJECT_NAME}.service" ];
    requires = [ "update-${PROJECT_NAME}.service" ];
  };
}
