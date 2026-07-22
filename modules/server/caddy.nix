# Native Caddy: the only public web ingress (ports 80/443). Serves static sites from
# /srv/websites/<site>/current and reverse-proxies analytics later.
# IMPORTANT: add a virtualHost only once its DNS A record already resolves to this box,
# otherwise ACME HTTP-01 issuance fails and can hit Let's Encrypt rate limits.
{ config, pkgs, lib, ... }:
let
  # Conservative, non-committal headers. No HSTS yet on the preview subdomain (HSTS is a
  # long-lived browser commitment); add it at the apex cutover (M8).
  secHeaders = ''
    header {
      X-Content-Type-Options "nosniff"
      X-Frame-Options "SAMEORIGIN"
      Referrer-Policy "strict-origin-when-cross-origin"
      -Server
    }
  '';
in
{
  services.caddy = {
    enable = true;
    email = "onyr.maintainer@gmail.com"; # ACME contact for cert-expiry notices

    virtualHosts."new.onyr.net".extraConfig = ''
      root * /srv/websites/onyr/current
      encode gzip zstd
      file_server
      ${secHeaders}
    '';

    virtualHosts."mamut-routing.onyr.net".extraConfig = ''
      @health path /api/healthz
      handle @health {
        header Content-Type application/json
        respond `{"status":"ok"}` 200
      }

      @siteFile file {
        root /srv/websites/mamut-routing/current/dist
        try_files {path} {path}/index.html
      }
      handle @siteFile {
        root * /srv/websites/mamut-routing/current/dist
        rewrite * {file_match.relative}
        file_server {
          precompressed br gzip
        }
      }

      @repoArtifact path /benchmarks/* /LICENSE
      handle @repoArtifact {
        root * /srv/websites/mamut-routing/current
        file_server {
          precompressed br gzip
        }
      }

      respond 404
      ${secHeaders}
    '';

    virtualHosts."analytics.onyr.net".extraConfig = ''
      encode gzip zstd
      reverse_proxy 127.0.0.1:3000
      ${secHeaders}
    '';
  };
}
