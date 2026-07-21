# Static website release directories. Layout: /srv/websites/<site>/current -> releases/<id>.
# Release dirs are owned deploy:webdeploy with setgid so CI-written files stay group-writable
# and world-readable (Caddy, running as user `caddy`, reads them via "other" perms).
{ config, pkgs, lib, ... }:
{
  systemd.tmpfiles.rules = [
    "d /srv/websites                          0755 root   webdeploy - -"
    "d /srv/websites/onyr                     2775 deploy webdeploy - -"
    "d /srv/websites/onyr/releases            2775 deploy webdeploy - -"
    "d /srv/websites/onyr/releases/bootstrap  2775 deploy webdeploy - -"
    # Seed current -> bootstrap ONLY if it does not exist yet.
    # Use "L" (not "L+") so a later deploy's symlink is never clobbered on rebuild/boot.
    "L /srv/websites/onyr/current             - - - - releases/bootstrap"
  ];

  systemd.services.seed-websites = {
    description = "Seed a placeholder index.html for the onyr bootstrap release";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-tmpfiles-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      f=/srv/websites/onyr/releases/bootstrap/index.html
      if [ ! -e "$f" ]; then
        echo '<!doctype html><meta charset=utf-8><title>zynzen</title><h1>new.onyr.net is live</h1><p>Served by Caddy on zynzen. The Jekyll deploy lands here at M5.</p>' > "$f"
        chgrp webdeploy "$f" 2>/dev/null || true
      fi
    '';
  };
}
