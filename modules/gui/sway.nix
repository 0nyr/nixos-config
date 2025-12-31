{ config, pkgs, pkgs-stable, lib, ... }:

let
  # NOTE: Need to build flameshot with Wayland support.
  # Use stable packages for rock-solid desktop utilities
  pkgsWithWaylandFlameshot = pkgs-stable.extend (final: prev: {
    flameshot = prev.flameshot.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or []) ++ [ "-DUSE_WAYLAND_GRIM=ON" ];
    });
  });
in {
  environment.systemPackages = with pkgsWithWaylandFlameshot; [
    flameshot
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    lxqt.lxqt-policykit # polkit agent for wayland
  ];

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # enable polkit for permission management
  security.polkit.enable = true;

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true; # provides xdg-desktop-portal-wlr (don't add it to extraPortals too!)
    config.common.default = "*";
    extraPortals = with pkgs-stable; [
      #xdg-desktop-portal-gtk # already present due to Gnome being installed.
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}