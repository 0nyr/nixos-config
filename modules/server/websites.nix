# Static website release directories. Layout: /srv/websites/<site>/current -> releases/<id>.
# Each release tree is writable by exactly one deployment account and world-readable by Caddy.
# The deployment of each site creates its releases and the `current` link. Until the first
# deployment, `current` does not exist and Caddy answers 404 for that site.
{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /srv/websites                                0755 root         root         - -"
    "d /srv/websites/onyr                           0755 deploy-onyr  deploy-onyr  - -"
    "d /srv/websites/onyr/releases                  0755 deploy-onyr  deploy-onyr  - -"
    "d /srv/websites/mamut-routing                  0755 deploy-mamut deploy-mamut - -"
    "d /srv/websites/mamut-routing/releases         0755 deploy-mamut deploy-mamut - -"
  ];
}
