{ config, pkgs, ... }:

let

### Project Settings
PROJECT_NAME = "baserow";
PROJECT_BASE_URL = "${PROJECT_NAME}.thecodingadventure.com";

DATA_DIR = "/home/baserow";

### Container Images
BASEROW_TAG = "docker.io/baserow/baserow:latest";

in {
  virtualisation.oci-containers.containers."${PROJECT_NAME}" = {
    image = BASEROW_TAG;
    autoStart = true;
    environment = {
      BASEROW_PUBLIC_URL = "https://${PROJECT_BASE_URL}";
    };
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.${PROJECT_NAME}.rule" = "Host(`${PROJECT_BASE_URL}`)";
      "traefik.http.routers.${PROJECT_NAME}.entrypoints" = "websecure";
      "traefik.http.routers.${PROJECT_NAME}.tls.certresolver" = "resolver";
    };
    volumes = [
      "${DATA_DIR}:/baserow/data"
    ];
  };

  services.traefik.staticConfigOptions.networks."${PROJECT_NAME}" = {
    name = "${PROJECT_NAME}";
    external = true;
  };

  systemd.services."update-${PROJECT_NAME}" = {
    description = "Create ${PROJECT_NAME} folder structure";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/bash -eu -c 'mkdir -p \"${DATA_DIR}\"'";
    };
  };
}
