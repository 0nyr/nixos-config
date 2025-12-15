{ config, pkgs, pkgs-stable, lib, ...}:

{
  # Fonts - use stable for rock-solid font packages
  fonts.packages = with pkgs-stable; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.tinos
  ];
}