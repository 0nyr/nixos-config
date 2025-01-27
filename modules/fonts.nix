{ config, pkgs, lib, ...}:

{
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.tinos
  ];
}