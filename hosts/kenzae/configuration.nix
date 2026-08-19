# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, pkgs-stable, inputs, ... }:

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
      ../../modules/keyring-secrets.nix
      ../../modules/sound.nix
      ../../modules/greetd.nix
      ../../modules/nixconf.nix
      ../../modules/nix-ld.nix
      # Home Manager (dotagents symlinks for Claude Code + Codex).
      ../../modules/home-manager.nix
      # GUI, desktop, and window manager configuration.
      ../../modules/gui/gnome.nix
      ../../modules/gui/sway.nix
    ];
  
  networking.hostName = "kenzae"; # Define your hostname.

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

  # Panic (and auto-reboot) on kernel hard lockups and hung tasks instead of
  # freezing silently with no trace, as happened on 2026-07-08 (no OOM, no
  # lockup detection, journal just stopped).
  boot.kernel.sysctl."kernel.hardlockup_panic" = 1;
  boot.kernel.sysctl."kernel.hung_task_panic" = 1;
  boot.kernel.sysctl."kernel.panic" = 10; # seconds before auto-reboot after a panic

  # Critical-battery handling. The upstream default action is HybridSleep,
  # which cannot work on this machine: swap is 8 GiB against 62 GiB of RAM, so
  # the hibernation image never fits. On 2026-08-18 the battery hit the 2%
  # trigger, hybrid-sleep started writing the image and the machine died
  # mid-write (next boot: "PM: Image not found (code -22)"), needing a hard
  # power off. PowerOff is the only action that is safe until swap is resized.
  #
  # The thresholds are also raised because the BAT0 gauge on this unit is
  # degraded and erratic (it fell from 92% to 8% in under 7 minutes), so 2%
  # gives no usable warning.
  services.upower = {
    enable = true;
    criticalPowerAction = "PowerOff";
    percentageAction = 5;
    percentageCritical = 10;
    percentageLow = 25;
  };

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

  # Unlock the gnome-keyring "login" keyring automatically at login, using the
  # password typed into tuigreet (greetd's PAM service). This is what lets the
  # SSH key passphrase (and the gh token) live in the keyring and be available
  # after login without retyping. Without this, the keyring stays locked and
  # every secret access prompts.
  security.pam.services.greetd.enableGnomeKeyring = true;

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

  # # Enable VirtualBox
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.dragAndDrop = true;

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
