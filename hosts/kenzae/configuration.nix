# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../../modules/boot.nix
    ../../modules/packages.nix
    ./hardware-configuration.nix
    # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    inputs.nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
    inputs.minegrub-theme.nixosModules.default
    inputs.home-manager.nixosModules.default
  ];

  networking.hostName = "kenzae"; # Define your hostname.

  networking.networkmanager.enable = true; # Enable networking

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
  services.pulseaudio.enable = false;
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
  services.libinput.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.tinos
  ];


  # ------------------------------------------
  # GUI
  # ------------------------------------------

  # Hyprland
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # Optional, hint electron apps to use wayland:
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      # wayland = true;
    };
    desktopManager.gnome.enable = false;
    windowManager.i3.enable = true;
    desktopManager.runXdgAutostartIfNone = true;
    #videoDrivers = ["nvidia"]; # Load nvidia driver for Xorg and Wayland
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
    dunst # notification
    libnotify # notification
    lxappearance # for theming in X11
    adwaita-icon-theme # for icons
  ];

  # # Enable OpenGL
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  #   # https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/intel/default.nix
  #   # https://nixos.wiki/wiki/Accelerated_Video_Playback
  #   extraPackages = with pkgs; [
  #     (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
  #     libvdpau-va-gl
  #     intel-media-driver
  #   ];
  # };
  
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

  # hardware.nvidia = {

  #   # Modesetting is required.
  #   modesetting.enable = true;

  #   # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  #   powerManagement.enable = false;
  #   # Fine-grained power management. Turns off GPU when not in use.
  #   # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  #   powerManagement.finegrained = false;

  #   # Use the NVidia open source kernel module (not to be confused with the
  #   # independent third-party "nouveau" open source driver).
  #   # Support is limited to the Turing and later architectures. Full list of 
  #   # supported GPUs is at: 
  #   # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
  #   # Only available from driver 515.43.04+
  #   # Currently alpha-quality/buggy, so false is currently the recommended setting.
  #   open = false;

  #   # Enable the Nvidia settings menu,
  #   # accessible via `nvidia-settings`.
  #   nvidiaSettings = true;

  #   # NVIDIA driver (select appropriate package for your card)
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;

  #   # Enable Optimus Prime support
  #   prime = {
      
  #     offload = {
  # 		  enable = false;
  #       enableOffloadCmd = lib.mkIf config.hardware.nvidia.prime.offload.enable true; # Provides `nvidia-offload` command.
  # 	  };
      
  #     # $ sudo lshw -c display
  #     intelBusId = "PCI:0:2:0";
  #     nvidiaBusId = "PCI:1:0:0";
  #   };
  # };

  # ------------------------------------------
  # User and packages
  # ------------------------------------------

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.onyr = {
    isNormalUser = true;
    description = "onyr";
    home = "/home/onyr";
    extraGroups = [ "audio" "networkmanager" "wheel" "docker" "storage" "vboxusers" ];
    packages = with pkgs; [
      # applications
      firefox
      brave
      vscode.fhs
      eclipses.eclipse-java 
      thunderbird # amazing email client
      zotero # reference manager for research
      discord # chat
      libreoffice # office suite, libre version of MS Office
      obsidian # note taking app
      pdfannots2json # command line utility for Obsidian (Zotero Integration plugin)
      krita # painting and image editing
      inkscape # vector graphics editor
      vlc # the famous media player
      tenacity # audio editor, fork of Audacity

      # games
      prismlauncher # For Minecraft
    ];
  };

  # nixpkgs.config.permittedInsecurePackages = [
  #   "electron-25.9.0" # for obsidian, TO BE REMOVED IN THE FUTURE
  # ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.steam.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
  system.stateVersion = "23.11"; # Did you read the comment?

}
