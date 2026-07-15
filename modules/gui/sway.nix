{ config, pkgs, pkgs-stable, lib, ... }:

let
  # NOTE: Need to build flameshot with Wayland support.
  # Use stable packages for rock-solid desktop utilities
  pkgsWithWaylandFlameshot = pkgs-stable.extend (final: prev: {
    flameshot = prev.flameshot.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or []) ++ [ "-DUSE_WAYLAND_GRIM=ON" ];
    });
  });
in {
  environment.systemPackages = with pkgsWithWaylandFlameshot; [
    flameshot
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    polkit_gnome # polkit agent for wayland (replaces lxqt which had auth dialog bugs)
  ];

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # gnome-keyring/gcr provides an SSH agent at $XDG_RUNTIME_DIR/gcr/ssh and
  # registers it in the *systemd user* environment. But sway is launched by
  # greetd (not by systemd), so terminals spawned from sway do NOT inherit
  # SSH_AUTH_SOCK. Export it for interactive shells so ssh/git use the agent.
  # Guarded on the socket existing, so bare TTY / remote-SSH sessions (no gcr
  # agent) are unaffected. NB: sway's `exec_always { export ... }` block does
  # NOT propagate env to terminals (throwaway subshell), which is why this is
  # done at the shell-init level instead.
  environment.interactiveShellInit = ''
    if [ -S "$XDG_RUNTIME_DIR/gcr/ssh" ]; then
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
    fi
  '';

  # enable polkit for permission management
  security.polkit.enable = true;

  # start polkit authentication agent on login
  # NOTE: Sway doesn't activate graphical-session.target, so we use default.target
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "default.target" ];
    after = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true; # provides xdg-desktop-portal-wlr (don't add it to extraPortals too!)
    config.common.default = "*";
    extraPortals = with pkgs-stable; [
      #xdg-desktop-portal-gtk # already present due to Gnome being installed.
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}