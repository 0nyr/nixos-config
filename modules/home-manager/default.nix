# User-level Home Manager entrypoint for `onyr`.
#
# Kept minimal for the Kenzae-first rollout: it only enables HM and pulls in the
# dotagents symlink map. The hyprland/desktop user config currently in
# modules/home.nix is intentionally NOT imported here yet; folding that in (and
# unifying both hosts onto this module) is a deliberate follow-up.
{ config, pkgs, pkgs-stable, inputs, lib, ... }:
{
  imports = [
    ./agents.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "onyr";
    homeDirectory = "/home/onyr";
    stateVersion = "25.05";
  };
}
