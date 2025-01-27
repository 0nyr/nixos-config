# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Input packages
    inputs.minegrub-theme.nixosModules.default
    inputs.home-manager.nixosModules.default
    # Boot
    ./boot.nix
    # Other configuration files.
    ./nvidia.nix
    ./fonts.nix
    ./keymap.nix
    ./onyr.nix
    ./packages.nix
    ./sound.nix
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Experimental setup
  nix.settings.experimental-features = ["nix-command" "flakes" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # secret management: https://www.reddit.com/r/NixOS/comments/1auje1p/hyprland_and_secrets_management/
  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true; # Enable the X11 windowing system
    #displayManager.gdm.enable = true;
    desktopManager.runXdgAutostartIfNone = true;
    xkb = {
      layout = "fr";
      variant = "";
    }; # Configure keymap in X11
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # On 64-bit systems, whether to also install 32-bit drivers for 32-bit applications (such as Wine).
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gparted
    neofetch
    lshw
    sshpass
    networkmanagerapplet
    pavucontrol
  ];

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
}
