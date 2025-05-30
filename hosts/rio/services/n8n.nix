{ config, pkgs, ... }:

let

### Project Settings
PROJECT_NAME = "n8n";
PROJECT_BASE_URL = "${PROJECT_NAME}.thecodingadventure.com";

DATA_DIR = "/home/n8n";

### Container Images
N8N_TAG = "docker.n8n.io/n8nio/n8n";

in {
  virtualisation.oci-containers.containers."${PROJECT_NAME}" = {
    image = N8N_TAG;
    autoStart = true;
    ports = [ "5678:5678" ];
    environment = {
      N8N_HOST = PROJECT_BASE_URL;
      WEBHOOK_URL	= "https://${PROJECT_BASE_URL}";
    };
    labels = {
      "traefik.enable" = "true";
      "traefik.http.services.${PROJECT_NAME}.loadbalancer.server.port" = "5678";
      "traefik.http.routers.${PROJECT_NAME}.rule" = "Host(`${PROJECT_BASE_URL}`)";
      "traefik.http.routers.${PROJECT_NAME}.entrypoints" = "websecure";
      "traefik.http.routers.${PROJECT_NAME}.tls.certresolver" = "resolver";
    };
    volumes = [
      "${DATA_DIR}:/home/node/.n8n"
    ];
    user = "node:node";
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
