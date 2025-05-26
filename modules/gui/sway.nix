{ config, pkgs, lib, ... }:

let
  # NOTE: Need to build flameshot with Wayland support.
  pkgsWithWaylandFlameshot = pkgs.extend (final: prev: {
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
  ];

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}