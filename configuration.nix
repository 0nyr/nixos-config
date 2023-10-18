# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

let
  # efi mount point :
  EFI_MOUNTPOINT = "/boot/efi";
  #user name
  USER_NAME = "onyr";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # ------------------------------------------
  # Bootloader
  # ------------------------------------------

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
      device = "nodev";
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

  # ------------------------------------------
  # File system
  # ------------------------------------------
  
  # File system configuration
  fileSystems."/home" = { # mount home 
    device = "/dev/nvme0n1p8"; # Adjust if the device path is different
    fsType = "ext4";           
  };

  fileSystems."${EFI_MOUNTPOINT}" = { # mount efi
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  # ------------------------------------------
  # Divers setup
  # ------------------------------------------
  
  # enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # bluetooth
  hardware.bluetooth.enable = true;

  # opengl
  hardware.opengl.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # ------------------------------------------
  # GUI
  # ------------------------------------------

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Configure keymap in X11
    layout = "fr";
    xkbOptions = "eurosign:e,caps:escape";

    displayManager.defaultSession = "myI3";
    displayManager.session = [
      {
        manage = "desktop";
        name = "myI3";
        # start i3 in debug mode
        #start = ''exec i3 --shmlog-size=26214400'';
        # start i3 in normal mode
        start = ''exec i3'';
      }
    ];

    windowManager.i3 = {
      enable = true;

      extraPackages = with pkgs; [
        # i3 specific packages
        i3status
        dmenu
        (polybar.override { pulseSupport = true; i3Support = true; })
        bc
        kitty # terminal
        shutter # screenshot
        rofi # application launcher menu
        xss-lock # screen saver
        i3lock-color
        brightnessctl
        networkmanagerapplet
        feh # wallpaper
        blueberry # bluetooth manager
        stacer # system monitor
     ];
    };

    displayManager.gdm.enable = true;
    #videoDrivers = [ "nvidia" ];
    #displayManager.defaultSession = "none+i3";
  };
  
  # configure console keymap
  console = {
    keyMap = "fr";
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [
      "FiraCode" "JetBrainsMono"
    ]; })
  ];  

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  nixpkgs.config.allowUnfree = true; # allow unfree licence packages, like VSCode users.users.<myuser>.;
  users.users."${USER_NAME}" = {
    isNormalUser = true;
    home = "/home/${USER_NAME}";       # Home directory path
    createHome = false;        # Don't create the home directory since it's a mount point
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user
    
    packages = with pkgs; [
      firefox
      thunderbird
      vscode
      tree
      pavucontrol
      zotero
      discord
      minecraft
      gnome.gnome-terminal
      gnome.nautilus
      gnome.gnome-tweaks
      gnome.evince # pdf reader
      gnome.eog # image viewer
      libreoffice
      obsidian
      krita
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # stable packages here
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gedit
    git
    htop
    neofetch
    openssl
    direnv
    usbutils
    appimage-run
    gparted
    python3 # for scripting (add no packages here, use dev shell instead)
    sshpass
    wireguard-tools # VPN
    openvpn # VPN
    openconnect # VPN
  ];
  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;

  # clipboard deamon
  services.greenclip.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

