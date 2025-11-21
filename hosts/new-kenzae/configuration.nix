# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # General configuration files.
      ../../modules/time.nix
      ../../modules/nvidia.nix
      ../../modules/fonts.nix
      ../../modules/keymap.nix
      ../../modules/onyr.nix
      ../../modules/packages.nix
      ../../modules/sound.nix
      ../../modules/greetd.nix
      ../../modules/nixconf.nix
      # GUI, desktop, and window manager configuration.
      ../../modules/gui/gnome.nix
      ../../modules/gui/sway.nix
    ];
  
  networking.hostName = "nixos"; # Define your hostname.

  # Enable the X11 windowing system, use GDM as Login Screen (Display Manager),
  services.xserver = {
    enable = true; # Enable the X11 windowing system
    #displayManager.gdm.enable = true;
    #desktopManager.runXdgAutostartIfNone = true;
    xkb = {
      layout = "fr";
      variant = "";
    }; # Configure keymap in X11
  };

  # Bootloader. 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ########### configuration.nix ###########

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Experimental setup
  nix.settings.experimental-features = ["nix-command" "flakes" ];

  # secret management: https://www.reddit.com/r/NixOS/comments/1auje1p/hyprland_and_secrets_management/
  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # bluetooth
  hardware.bluetooth.enable = true;

  # Enable auto mounting of removable media
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable VirtualBox
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
