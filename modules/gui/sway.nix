{ config, pkgs, pkgs-stable, lib, ... }:

let

  # Menu shown when an application asks to share the screen. Without it, the
  # portal falls back to `slurp`, which silently waits for a click on the
  # screen to share.
  screenShareChooser = pkgs.writeShellApplication {
    name = "screen-share-chooser";
    runtimeInputs = with pkgs; [ sway jq lswt wofi wayland-utils gnugrep ];
    text = builtins.readFile ./screen-share-chooser.sh;
  };

  # json-c 0.19 frees containers inside assert(), so its NDEBUG build leaks
  # every non-empty object. Sway builds each IPC reply and event with json-c,
  # and waybar queries the tree on every window event, so a title animation
  # drove sway to 64 GiB of heap in 5 hours (sway issue 9347). The fix is
  # json-c commit f291fa81c (json-c PR 936), unreleased and not yet in
  # nixos-unstable (nixpkgs PR 586077). Only sway gets the patched json-c,
  # which avoids rebuilding every dependent of json-c. Once the channel ships
  # the patch, the warning below fires, and jsonCFixed and the sway override
  # can then be dropped.
  jsonCFixPatch = pkgs.fetchpatch {
    url = "https://github.com/json-c/json-c/commit/f291fa81c6f21d925ea771a8cca597f5886309cc.patch";
    hash = "sha256-ZffSw1pfEfOH2ylRpJShdx7sTQR2nmPM/JIj/26UrDM=";
  };
  jsonCFixed =
    if (pkgs.json_c.patches or [ ]) == [ ] && pkgs.json_c.version == "0.19" then
      pkgs.json_c.overrideAttrs (old: { patches = [ jsonCFixPatch ]; })
    else
      lib.warn "modules/gui/sway.nix: nixpkgs json-c now carries patches or is no longer 0.19, drop the jsonCFixed override" pkgs.json_c;
  swayFixed = pkgs.sway.override {
    sway-unwrapped = pkgs.sway-unwrapped.override { json_c = jsonCFixed; };
  };
in {
  # Stable packages for rock-solid desktop utilities.
  environment.systemPackages = with pkgs-stable; [
    # Flameshot 13 captures through grim on wlroots compositors when
    # `useGrimAdapter=true` is set in ~/.config/flameshot/flameshot.ini
    # (tracked in the dotfiles repository). The former USE_WAYLAND_GRIM
    # compile flag no longer exists.
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

  # Run Firefox and Thunderbird as native Wayland clients whoever launches
  # them. X11 applications such as Discord export GDK_BACKEND=x11 to their
  # children, so a link clicked there used to start Firefox under XWayland,
  # where screen sharing shows a black image.
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

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
    package = swayFixed; # json-c leak fix, see jsonCFixed above
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true; # provides xdg-desktop-portal-wlr (don't add it to extraPortals too!)
    # Cap screen capture at 30 frames per second. Uncapped, a shared screen is
    # captured at the output's refresh rate (240 Hz on Kenzae's panel).
    wlr.settings.screencast = {
      max_fps = 30;
      chooser_type = "simple";
      chooser_cmd = "${screenShareChooser}/bin/screen-share-chooser";
    };
    config.common.default = "*";
    extraPortals = with pkgs-stable; [
      #xdg-desktop-portal-gtk # already present due to Gnome being installed.
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}