# Privacy-oriented analytics stack. Only Umami is reachable through Caddy;
# PostgreSQL stays on the private container network and pgAdmin is manual-start.
{ config, inputs, pkgs, ... }:
let
  networkName = "zynzen-analytics";
  postgresContainer = "zynzen-postgres";
  dockerPackage = pkgs.docker_29;
in
{
  virtualisation.docker = {
    enable = true;
    package = dockerPackage;
  };
  virtualisation.oci-containers.backend = "docker";

  sops = {
    defaultSopsFile = "${inputs.nixos-secrets}/zynzen.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      postgres_password = { };
      umami_app_secret = { };
      umami_admin_password = { };
      pgadmin_email = { };
      pgadmin_password = { };
    };
    templates = {
      "postgres.env" = {
        mode = "0400";
        content = ''
          POSTGRES_DB=umami
          POSTGRES_USER=umami
          POSTGRES_PASSWORD=${config.sops.placeholder.postgres_password}
        '';
      };
      "umami.env" = {
        mode = "0400";
        content = ''
          DATABASE_URL=postgresql://umami:${config.sops.placeholder.postgres_password}@${postgresContainer}:5432/umami
          APP_SECRET=${config.sops.placeholder.umami_app_secret}
        '';
      };
      "pgadmin.env" = {
        mode = "0400";
        content = ''
          PGADMIN_DEFAULT_EMAIL=${config.sops.placeholder.pgadmin_email}
          PGADMIN_DEFAULT_PASSWORD=${config.sops.placeholder.pgadmin_password}
          PGADMIN_LISTEN_PORT=80
        '';
      };
    };
  };

  systemd.services.analytics-container-network = {
    description = "Create the private analytics container network";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    before = [
      "docker-${postgresContainer}.service"
      "docker-zynzen-umami.service"
      "docker-zynzen-pgadmin.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${dockerPackage}/bin/docker network inspect ${networkName} >/dev/null 2>&1 || \
        ${dockerPackage}/bin/docker network create ${networkName} >/dev/null
    '';
  };

  virtualisation.oci-containers.containers = {
    "${postgresContainer}" = {
      image = "docker.io/library/postgres@sha256:8189a1f6e40904781fc9e2612687877791d21679866db58b1de996b31fc312e4";
      environmentFiles = [ config.sops.templates."postgres.env".path ];
      volumes = [ "zynzen-postgres-data:/var/lib/postgresql/data" ];
      extraOptions = [
        "--network=${networkName}"
        "--health-cmd=pg_isready -U umami -d umami"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=6"
      ];
    };

    zynzen-umami = {
      image = "ghcr.io/umami-software/umami@sha256:8edfe4beaef13f9d1300619fa264ef250a3688df9cc54d24ca830ca31cb475ec";
      environmentFiles = [ config.sops.templates."umami.env".path ];
      ports = [ "127.0.0.1:3000:3000" ];
      dependsOn = [ postgresContainer ];
      extraOptions = [
        "--network=${networkName}"
        "--health-cmd=curl --fail http://localhost:3000/api/heartbeat"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=12"
      ];
    };

    zynzen-pgadmin = {
      image = "docker.io/dpage/pgadmin4@sha256:40fa840c5bb7c8463957f1255b01283732c2d8c9396a956d180f8e6c296753b3";
      environmentFiles = [ config.sops.templates."pgadmin.env".path ];
      ports = [ "127.0.0.1:5050:80" ];
      volumes = [ "zynzen-pgadmin-data:/var/lib/pgadmin" ];
      autoStart = false;
      extraOptions = [ "--network=${networkName}" ];
    };
  };

  systemd.services."docker-${postgresContainer}" = {
    after = [ "analytics-container-network.service" ];
    requires = [ "analytics-container-network.service" ];
  };
  systemd.services.docker-zynzen-umami = {
    after = [ "analytics-container-network.service" ];
    requires = [ "analytics-container-network.service" ];
  };
  systemd.services.docker-zynzen-pgadmin = {
    after = [ "analytics-container-network.service" ];
    requires = [ "analytics-container-network.service" ];
  };
}
