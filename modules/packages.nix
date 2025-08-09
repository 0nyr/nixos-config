{ config, pkgs, lib, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    code-cursor-fhs
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
    megasync # MEGA cloud sync WARN: wait for freeimage dependency.
    networkmanagerapplet # for network applet on bar
    pavucontrol # for advanced sound control
    alsa-utils # for alsamixer
    qjackctl # jack audio app to control the JACK sound server daemon
    qpwgraph # for visualizing PipeWire graph, equivalent to what qjackctl is to JACK
    pciutils # for PCI utilities (like listing audio cards)
    hw-probe # for hardware and driver probing $ sudo -E hw-probe -all -upload
    keepassxc # password manager
    tmux # terminal multiplexer
    ffmpeg-full # Complete, cross-platform solution to record, convert and stream audio and video

    # Hyprland or Sway (Wayland) packages
    mesa-demos # for testing nvidia offloading. $ glxgears -info
    wofi # Application launcher
    waybar # Status bar
    pamixer # for waybar audio
    rofi-wayland # Alternate application launcher for Wayland
    wl-clipboard # Clipboard utilities for Wayland
    swaylock # Screen locker for Wayland
    swayidle # Idle management daemon for Wayland
    swaynotificationcenter # Notification center for Sway, compatible with other Wayland compositors
    mako # notification system developed by swaywm maintainer
    swww # Wayland wallpapers
    pipewire # Audio and video routing and processing
    wireplumber # Session and policy manager for Pipewire
    qt5.qtwayland # QT5 support for Wayland
    qt6.qtwayland # QT6 support for WaylandPersonne à contacter au sujets des formations de l'[[école doctorale SPIN]]on bar
    brightnessctl # for screen brightness
    kitty # terminal
    blueberry # bluetooth manager
    stacer # system monitor
    zoom-us # video conference
    # ventoy-full # makebootable usb - temporarily disabled due to being insecure: https://github.com/NixOS/nixpkgs/issues/404663
    nwg-look # for theming GTK apps
    libsForQt5.qtstyleplugin-kvantum # for theming QT apps
    grim # screenshot functionality
    slurp # screenshot functionality

    # Gnome apps
    gnome-terminal
    nautilus 
    kdePackages.dolphin # KDE file explorer
    gnome-tweaks
    evince # pdf reader
    gnome-calculator
    eog # image viewer
    gnome-calendar
  ];
}