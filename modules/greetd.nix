# Greetd is a Login Manager (AKA Display Manager) for Wayland
# It is responsible for starting the Wayland session and managing user logins.
# It is a lightweight alternative to GDM, SDDM, or LightDM.
# It supports various greeters, including tui-greet, which provides a terminal-based login interface.
# See: https://www.drakerossman.com/blog/wayland-on-nixos-confusion-conquest-triumph#display-server
{
  pkgs, pkgs-stable, ...
}:

{
  # Ensure that the greetd service has access to sway - use stable for login components
  environment.systemPackages = with pkgs-stable; [
    tuigreet
    sway
  ];

  # NB: check greetd logs: journalctl -xeu greetd.service
  services.greetd = {
    enable = true;
    settings = {
      # NB: keep this on a single line. A multi-line Nix string embeds real
      # newlines into the generated TOML as a multi-line literal string,
      # which greetd's TOML parser fails to load ("expected equals sign on
      # line, but found none"), even though the TOML itself is spec-valid.
      #
      # We deliberately do NOT use `dbus-run-session` here. It spawns a fresh,
      # throwaway D-Bus session bus for the whole sway session, isolated from
      # the systemd *user* bus ($XDG_RUNTIME_DIR/bus) where pam_gnome_keyring
      # unlocks the login keyring at login. On the throwaway bus, secret
      # requests activate a second, LOCKED keyring daemon, which is what
      # produced the "login keyring did not get unlocked" prompt on every
      # login (diagnosed 2026-07-15). Instead we point the session at the
      # systemd user bus so sway, portals, and the unlocked keyring all share
      # one bus. XDG_RUNTIME_DIR is set by pam_systemd before this runs; the
      # `$` is literal in this Nix string (only `''${` interpolates), so the
      # shell expands it at session start.
      default_session.command = ''${pkgs-stable.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd "DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus sway --unsupported-gpu > /tmp/sway.log 2>&1"'';
    };
  };
}