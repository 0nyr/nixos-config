# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../../modules/configuration.nix
    ./hardware-configuration.nix
    # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    inputs.nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
  ];

  networking.hostName = "kenzae"; # Define your hostname.

  # see https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/intel/default.nix
  # and https://github.com/NixOS/nixos-hardware/blob/master/tuxedo/infinitybook/pro14/gen7/default.nix
  hardware.graphics = {
    extraPackages = with pkgs; [
      (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };
  
  # see https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix
  # and https://github.com/NixOS/nixos-hardware/blob/master/tuxedo/infinitybook/pro14/gen7/default.nix
  services.fstrim.enable = lib.mkDefault true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Install Steam
  programs.steam.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
