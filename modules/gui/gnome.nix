{ config, pkgs, lib, ... }:

{
  services.xserver = {
    desktopManager.gnome.enable = true;
  };
}