{ config, pkgs, lib, ... }:

# Example: https://github.com/srid/nixos-config/blob/master/modules/nixos/linux/gui/hyprland/default.nix

{
  environment.systemPackages = with pkgs; [
    dunst # Notification daemon
    hyprshot # Screenshot utility
  ];

  programs.hyprland.enable = true;
  
  # Optional, hint electron apps to use wayland:
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # https://wiki.hyprland.org/Useful-Utilities/xdg-desktop-portal-hyprland/
      #xdg-desktop-portal-wlr
      #xdg-desktop-portal-gtk # already present due to Gnome being installed.
      xdg-desktop-portal-hyprland
    ];
  };

  security = {
    polkit.enable = true;
    # pam.services.ags = {};
  };
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}