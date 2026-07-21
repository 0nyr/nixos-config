# Headless OVH VPS "zynzen" — public web infrastructure (Caddy + static sites + analytics).
# Evaluated against nixpkgs-stable 25.11 via the flake output "zynzen".
#
# Self-contained on purpose: it does NOT import modules/onyr.nix or modules/nixconf.nix,
# because those carry desktop assumptions (groups networkmanager/docker/vboxusers/storage
# that don't exist on a headless host, and a Kenzae-local flake registry path).
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix   # generated on the box: nixos-generate-config --no-filesystems
    ./disko.nix                    # disk layout + GRUB (legacy BIOS on /dev/sda)
    ./networking.nix               # systemd-networkd, off-link gateway (GatewayOnLink)
    ../../modules/server/caddy.nix       # M4: native Caddy ingress + new.onyr.net
    ../../modules/server/websites.nix    # M4: /srv/websites release dirs + bootstrap
    # ../../modules/server/analytics.nix   # M7
  ];

  networking.hostName = "zynzen";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Nix (inline; see header for why we don't import modules/nixconf.nix) ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    "download-buffer-size" = 1073741824; # 1 GiB, matches modules/nixconf.nix
    # Let Kenzae-built closures deploy to onyr@ (in wheel) without per-path signatures.
    # onyr already has passwordless sudo (root-equivalent), so this grants no new privilege.
    trusted-users = [ "root" "@wheel" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [
    git curl vim htop jq dnsutils tcpdump rsync
  ];

  # --- Admin user (defined fresh; minimal groups for a headless host) ---
  users.users.onyr = {
    isNormalUser = true;
    description = "onyr";
    home = "/home/onyr";
    extraGroups = [ "wheel" "webdeploy" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/5tkNV280H/e7I/3gjhnR9/rRvuKlH4c6U1/DP0j7l rascoussier.florian@gmail.com kenzae"
    ];
  };
  security.sudo.wheelNeedsPassword = false; # key-only box; onyr has no password by default
  users.mutableUsers = true;                # keep `passwd` as an OVH-console break-glass

  # --- Restricted deploy user (CI rsync; no sudo). authorizedKeys set at M5. ---
  users.groups.webdeploy = { };
  users.users.deploy = {
    isSystemUser = true;
    group = "webdeploy";
    home = "/var/lib/deploy";
    createHome = true;
    shell = pkgs.bashInteractive;
    # openssh.authorizedKeys.keys = [ "<github-actions-deploy-pubkey>" ];  # M5
  };

  # --- SSH: key-only; onyr is the sole admin account. Root break-glass removed at M3
  #     (onyr + passwordless sudo gives the same root access; the real out-of-band
  #     emergency path is the OVH KVM console + rescue mode, not SSH). ---
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "onyr" "deploy" ];
    };
  };

  services.fail2ban.enable = true;

  # --- Firewall: only 22/80/443 public (covers IPv4 and IPv6) ---
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 443 ]; # HTTP/3 (QUIC); optional
  };

  # Installation baseline; do not casually change.
  system.stateVersion = "25.11";
}
