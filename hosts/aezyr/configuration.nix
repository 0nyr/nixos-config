# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../../modules/configuration.nix
    ./hardware-configuration.nix
    # GUI, desktop, and window manager configuration.
    ../../modules/gui/gnome.nix
    ../../modules/gui/sway.nix
    ../../modules/gui/hyprland.nix
    ../../modules/gui/i3.nix
  ];

  networking.hostName = "aezyr"; # Define your hostname.

  home-manager.users.onyr = import ./home.nix;

  # display manager
  services.displayManager.sddm.enable = true; # supported well by Hyprland
  security.pam.services.sddm.enableGnomeKeyring = true; # Enable the gnome-keyring secrets vault.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
