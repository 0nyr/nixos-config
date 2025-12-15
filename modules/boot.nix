{ config, pkgs, pkgs-stable, lib, ... }:

let
  # EFI mount point :
  EFI_MOUNTPOINT = "/boot";
in
{
  # Use GRUB as bootloader
  boot.loader = {
    timeout = 30;
    grub = {
      minegrub-theme = {
        enable = true;
        splash = "Per Aspera Ad Astra";
      };
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false; # set to true if needed
      device = "nodev"; # TODO: specify linux disk ??? No
      useOSProber = true;
      extraEntries = ''
        menuentry "Reboot" {
          reboot
        }
        menuentry "Poweroff" {
          halt
        }
      '';
    };
    efi = {
      efiSysMountPoint = "${EFI_MOUNTPOINT}"; # adjust if your mount point differs
      canTouchEfiVariables = true;
    };
  };
}