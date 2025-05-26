{ config, pkgs, lib, ... }:

{
  # Remember: You can switch to TTY with 

  environment.systemPackages = with pkgs; [
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
    extraPortals = with pkgs; [
      # https://wiki.hyprland.org/Useful-Utilities/xdg-desktop-portal-hyprland/
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}