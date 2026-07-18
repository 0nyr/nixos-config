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
    libsecret # provides secret-tool: CLI client for the gnome-keyring secret service (see gh-mamut below)
    unzip
    direnv
    fastfetch # Note: 'neofetch' has been removed because it is unmaintained upstream.
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
    wl-mirror # mirror/clone an output onto another for screen-sharing / presentations (Sway has no native clone)
    swaylock # Screen locker for Wayland
    swayidle # Idle management daemon for Wayland
    swaynotificationcenter # Notification center for Sway, compatible with other Wayland compositors
    libnotify # provides notify-send (used by scripts to post desktop notifications)
    awww # Wayland wallpapers
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
    telegram-desktop # messaging app

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

  # `gh` stores exactly one token per host per account, and our personal
  # fine-grained PAT is owned by the personal account `0nyr`, so it cannot act on
  # ANR-MAMUT resources: org-owned repos need a token whose *resource owner* is
  # the org (verified 2026-07-18: collaborators and actions/secrets both return
  # "403 Resource not accessible by personal access token"). Note that the
  # `permissions` field the API returns on those repos reflects the *user's*
  # rights, not the token's, so it misleadingly reads `admin: true`.
  #
  # Rather than swapping the stored token (which would break personal-repo `gh`
  # access), override it per-invocation from the keyring. Requires a one-time:
  #   secret-tool store --label="gh ANR-MAMUT PAT" service gh-mamut account 0nyr
  #
  # Kept at OS level (not in nix-dev-base) on purpose: secret-tool is a client of
  # the gnome-keyring service enabled in modules/gui/sway.nix and PAM-unlocked via
  # greetd, so it belongs to the same layer as that daemon. It is never a build
  # input for any project. OS-level also means it stays on PATH inside every
  # `nix develop` shell, whereas the reverse would leave this function broken in
  # plain (non-dev-shell) shells, which is where gh actually gets used.
  #
  # NB: environment.interactiveShellInit is types.lines, so this merges with the
  # SSH_AUTH_SOCK block defined in modules/gui/sway.nix rather than conflicting.
  #
  # The empty-token guard matters: with GH_TOKEN="" gh silently falls back to
  # *unauthenticated* requests instead of erroring, which surfaces as confusing
  # 404s on private resources rather than an auth failure. Fail loudly instead.
  environment.interactiveShellInit = ''
    gh-mamut() {
      local _tok
      _tok="$(secret-tool lookup service gh-mamut account 0nyr 2>/dev/null)"
      if [ -z "$_tok" ]; then
        echo "gh-mamut: no ANR-MAMUT token found in the keyring." >&2
        echo "Store one with:" >&2
        echo '  secret-tool store --label="gh ANR-MAMUT PAT" service gh-mamut account 0nyr' >&2
        echo "Create the token at https://github.com/settings/personal-access-tokens/new (Resource owner: ANR-MAMUT)." >&2
        return 1
      fi
      GH_TOKEN="$_tok" gh "$@"
    }
  '';
}