{ config, pkgs, pkgs-stable, lib, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ###### UNSTABLE PACKAGES (latest features, frequent updates) ######
    
    # CLI tools and utilities
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gh # GitHub CLI
    unzip
    direnv
    neofetch
    lshw # for hardware information
    htop
    tree
    openssl
    usbutils
    appimage-run
    python3 # for scripting (add no packages here, use dev shell instead)
    sshpass
    wireguard-tools # VPN
    openvpn # VPN
    openconnect # VPN
    killall # for killing processes
    tmux # terminal multiplexer
    ffmpeg-full # Complete, cross-platform solution to record, convert and stream audio and video
    hw-probe # for hardware and driver probing $ sudo -E hw-probe -all -upload

    # Hyprland or Sway (Wayland) packages
    mesa-demos # for testing nvidia offloading. $ glxgears -info
    wofi # Application launcher
    waybar # Status bar
    pamixer # for waybar audio
    rofi # Alternate application launcher for Wayland
    wl-clipboard # Clipboard utilities for Wayland
    swaylock # Screen locker for Wayland
    swayidle # Idle management daemon for Wayland
    swaynotificationcenter # Notification center for Sway, compatible with other Wayland compositors
    mako # notification system developed by swaywm maintainer
    swww # Wayland wallpapers
    pipewire # Audio and video routing and processing
    wireplumber # Session and policy manager for Pipewire
    qt5.qtwayland # QT5 support for Wayland
    qt6.qtwayland # QT6 support for Wayland
    brightnessctl # for screen brightness
    kitty # terminal
    grim # screenshot functionality
    slurp # screenshot functionality
    syncthing # continuous file synchronization program
    syncthingtray # System tray app for Syncthing
    megasync # MEGA cloud sync

    # Applications (unstable - benefit from frequent updates)
    brave # browser - security updates
    vscode.fhs # IDE - frequent updates
    eclipses.eclipse-java # IDE
    thunderbird # email client
    zotero # reference manager for research
    discord # chat
    libreoffice # office suite
    obsidian # note taking app - frequent updates
    pdfannots2json # command line utility for Obsidian (Zotero Integration plugin)
    krita # painting and image editing
    inkscape # vector graphics editor
    vlc # media player
    tenacity # audio editor, fork of Audacity
    davinci-resolve # video editor - frequent updates
    blender # 3D modeling and video editing - frequent updates
    obs-studio # screen recording
    simplescreenrecorder # screen recording
    kooha # screen recording

    # Games
    prismlauncher # For Minecraft
  ] ++ (with pkgs-stable; [
    ###### STABLE PACKAGES (rock-solid, infrequent changes) ######
    
    # Gnome apps - stable, reliable, don't need latest versions
    gedit
    gnome-terminal
    nautilus 
    gnome-tweaks
    evince # pdf reader
    gnome-calculator
    eog # image viewer
    gnome-calendar
    gnome-system-monitor

    # KDE apps
    kdePackages.dolphin # KDE file explorer

    # System utilities - stability preferred
    gparted
    networkmanagerapplet # for network applet on bar
    pavucontrol # for advanced sound control
    alsa-utils # for alsamixer
    qjackctl # jack audio app to control the JACK sound server daemon
    qpwgraph # for visualizing PipeWire graph
    pciutils # for PCI utilities (like listing audio cards)
    keepassxc # password manager
    blueberry # bluetooth manager
    zoom-us # video conference
    # ventoy-full # makebootable usb - temporarily disabled due to being insecure
    nwg-look # for theming GTK apps
    libsForQt5.qtstyleplugin-kvantum # for theming QT apps
  ]);
}