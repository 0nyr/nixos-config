# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../../modules/configuration.nix
    ../../modules/gui/i3.nix
    ./hardware-configuration.nix
    # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    inputs.nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
  ];

  networking.hostName = "kenzae"; # Define your hostname.

  # Display manager (gnome)
  services.xserver = {
    displayManager.gdm = {
      enable = true;
      # wayland = true;
    };
  };

      # discord freeze related: https://www.reddit.com/r/ManjaroLinux/comments/deo4x2/discord_freezes_when_getting_notifications/
    # https://discourse.nixos.org/t/sending-notifications-from-system-services/4825
    # WARN: should not be done on a machine where you do not trust the other users (see on https://search.nixos.org)
    services.systembus-notify.enable = true;

    # https://github.com/NixOS/nixpkgs/issues/349759
    nixpkgs.overlays = [
      (self: super: {
        tlp = super.tlp.overrideAttrs (old: {
          makeFlags = (old.makeFlags or [ ]) ++ [
            "TLP_ULIB=/lib/udev"
            "TLP_NMDSP=/lib/NetworkManager/dispatcher.d"
            "TLP_SYSD=/lib/systemd/system"
            "TLP_SDSL=/lib/systemd/system-sleep"
            "TLP_ELOD=/lib/elogind/system-sleep"
            "TLP_CONFDPR=/share/tlp/deprecated.conf"
            "TLP_FISHCPL=/share/fish/vendor_completions.d"
            "TLP_ZSHCPL=/share/zsh/site-functions"
          ];
        });
      })
    ];

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

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
