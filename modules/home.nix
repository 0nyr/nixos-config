{ config, pkgs, pkgs-stable, inputs, lib, ... }:
{
  programs = {
    home-manager.enable = true;
  };

  home = {
    username = "onyr";
    homeDirectory = "/home/onyr";
    stateVersion = "23.05";
  };
}
