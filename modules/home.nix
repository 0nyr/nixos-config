{ config, pkgs, pkgs-stable, inputs, lib, ... }:
{
  programs = {
    home-manager.enable = true;
  };

  home = {
    username = "onyr";
    homeDirectory = "/home/onyr";
    stateVersion = "23.05";
    file = {
      ".config/hypr/plugins.conf".text = ''
        plugin = ${inputs.hy3.packages.x86_64-linux.hy3}/lib/libhy3.so
      '';
      ".config/hypr/hyprland.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/onyr/dotfiles/hypr/hyprland.conf";
        recursive = true;
      };
    };
  };
}
