{ config, pkgs, pkgs-stable, lib, ... }:

{
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.onyr = {
    isNormalUser = true;
    description = "onyr";
    home = "/home/onyr";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" "storage" "video" "render" "vboxusers" ];
    # User packages moved to modules/packages.nix for centralized management
  };
}