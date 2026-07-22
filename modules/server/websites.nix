# Static website release directories. Layout: /srv/websites/<site>/current -> releases/<id>.
# Each release tree is writable by exactly one deployment account and world-readable by Caddy.
{ config, pkgs, lib, ... }:
{
  systemd.tmpfiles.rules = [
    "d /srv/websites                                0755 root         root         - -"
    "d /srv/websites/onyr                           0755 deploy-onyr  deploy-onyr  - -"
    "d /srv/websites/onyr/releases                  0755 deploy-onyr  deploy-onyr  - -"
    "d /srv/websites/onyr/releases/bootstrap        0755 deploy-onyr  deploy-onyr  - -"
    "d /srv/websites/mamut-routing                  0755 deploy-mamut deploy-mamut - -"
    "d /srv/websites/mamut-routing/releases         0755 deploy-mamut deploy-mamut - -"
    "d /srv/websites/mamut-routing/releases/bootstrap      0755 deploy-mamut deploy-mamut - -"
    "d /srv/websites/mamut-routing/releases/bootstrap/dist 0755 deploy-mamut deploy-mamut - -"
    # Seed current -> bootstrap ONLY if it does not exist yet.
    # Use "L" (not "L+") so a later deploy's symlink is never clobbered on rebuild/boot.
    "L /srv/websites/onyr/current             - - - - releases/bootstrap"
    "L /srv/websites/mamut-routing/current     - - - - releases/bootstrap"
  ];

  systemd.services.seed-websites = {
    description = "Seed placeholder pages for static website bootstrap releases";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-tmpfiles-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      onyr_file=/srv/websites/onyr/releases/bootstrap/index.html
      if [ ! -e "$onyr_file" ]; then
        echo '<!doctype html><meta charset=utf-8><title>zynzen</title><h1>new.onyr.net is live</h1><p>Served by Caddy on zynzen. The Jekyll deploy lands here at M5.</p>' > "$onyr_file"
        chown deploy-onyr:deploy-onyr "$onyr_file"
      fi
      mamut_file=/srv/websites/mamut-routing/releases/bootstrap/dist/index.html
      if [ ! -e "$mamut_file" ]; then
        echo '<!doctype html><meta charset=utf-8><title>MAMUT-routing mirror</title><h1>MAMUT-routing mirror staging</h1><p>The first verified mirror release is being prepared.</p>' > "$mamut_file"
        chown deploy-mamut:deploy-mamut "$mamut_file"
      fi
    '';
  };
}
