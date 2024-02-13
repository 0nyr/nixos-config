# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  # EFI mount point :
  EFI_MOUNTPOINT = "/boot";
  # user name
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
  # Divers setup
  # ------------------------------------------

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

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

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true; # Wireplumber as session manager for Pipewire
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [
      # Names of fonts to use:
      # -Tinos: Tinos
      # -FiraCode: Fira Code
      # -JetBrainsMono: 'JetBrainsMono Nerd Font'
      "FiraCode" "JetBrainsMono" "Tinos"
    ]; })
  ];  

  # ------------------------------------------
  # GUI
  # ------------------------------------------

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    windowManager.i3.enable = true;
    desktopManager.runXdgAutostartIfNone = true;
    videoDrivers = ["nvidia"]; # Load nvidia driver for Xorg and Wayland
    xkb = {
      layout = "fr";
      variant = "";
    }; # Configure keymap in X11
  };

  # i3 extra packages
  services.xserver.windowManager.i3.extraPackages = with pkgs; [
    # i3 specific packages
    i3status
    dmenu
    (polybar.override { pulseSupport = true; i3Support = true; })
    bc
    shutter # screenshot
    flameshot # screenshot
    rofi # application launcher menu
    xss-lock # screen saver
    i3lock-color
    feh # wallpaper
    xorg.xrandr # for dual screen
    arandr # GUI for xrandr
  ];

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    # https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/intel/default.nix
    # https://nixos.wiki/wiki/Accelerated_Video_Playback
    extraPackages = with pkgs; [
      (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # NVIDIA driver (select appropriate package for your card)
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Enable Optimus Prime support
    prime = {
      
      offload = {
			  enable = true;
        enableOffloadCmd = lib.mkIf config.hardware.nvidia.prime.offload.enable true; # Provides `nvidia-offload` command.
		  };
      
      # $ sudo lshw -c display
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ------------------------------------------
  # User and packages
  # ------------------------------------------

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.onyr = {
    isNormalUser = true;
    description = "onyr";
    home = "/home/onyr";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      # applications
      firefox
      brave
      vscode.fhs
      thunderbird
      zotero
      discord
      libreoffice
      obsidian
      krita
      inkscape
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # for obsidian, TO BE REMOVED IN THE FUTURE
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gedit
    git
    direnv
    neofetch
    lshw # for hardware information.
    htop
    tree
    openssl
    usbutils
    appimage-run
    gparted
    python3 # for scripting (add no packages here, use dev shell instead)
    sshpass
    wireguard-tools # VPN
    openvpn # VPN
    openconnect # VPN
    killall # for killing processes

    # Hyprland
    mesa-demos # for testing nvidia offloading. $ glxgears -info
    wofi # Application launcher
    waybar # Status bar
    pamixer # for waybar audio
    rofi-wayland # Alternate application launcher for Wayland
    xdg-desktop-portal-hyprland # XDG portals implementation for Hyprland
    xdg-desktop-portal-gtk # GTK portals for file dialogs, screenshots, etc.
    wl-clipboard # Clipboard utilities for Wayland
    swaylock # Screen locker for Wayland
    swayidle # Idle management daemon for Wayland
    swaynotificationcenter # Notification center for Sway, compatible with other Wayland compositors
    swww # Wayland wallpapers
    pipewire # Audio and video routing and processing
    wireplumber # Session and policy manager for Pipewire
    qt5.qtwayland # QT5 support for Wayland
    qt6.qtwayland # QT6 support for Wayland
    clipman # Clipboard manager
    wlogout # For logout screen
    pavucontrol # for advance sound control
    networkmanagerapplet # for network applet on bar
    brightnessctl # for screen brightness
    kitty # terminal
    blueberry # bluetooth manager
    stacer # system monitor
    zoom-us # video conference
    ventoy-full # makebootable usb
    flameshot # screenshot
    nwg-look # for theming GTK apps
    qt5ct # for theming QT5 apps
    libsForQt5.qtstyleplugin-kvantum # for theming QT apps

    # Gnome apps
    gnome.gnome-terminal
    gnome.nautilus
    gnome.gnome-tweaks
    gnome.evince # pdf reader
    gnome.gnome-calculator
    gnome.eog # image viewer
    gnome.gnome-calendar
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
  system.stateVersion = "23.11"; # Did you read the comment?

}
