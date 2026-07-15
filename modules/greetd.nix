# Greetd is a Login Manager (AKA Display Manager) for Wayland
# It is responsible for starting the Wayland session and managing user logins.
# It is a lightweight alternative to GDM, SDDM, or LightDM.
# It supports various greeters, including tui-greet, which provides a terminal-based login interface.
# See: https://www.drakerossman.com/blog/wayland-on-nixos-confusion-conquest-triumph#display-server
{
  pkgs, pkgs-stable, ...
}:

let
  # Session launcher for sway, run by greetd AS the logged-in user after their
  # PAM session is opened.
  #
  # Why a wrapper script (not an inline `--cmd`): we must point sway at the
  # systemd *user* D-Bus bus so the whole session shares the bus where
  # pam_gnome_keyring already unlocked the login keyring at login. We must NOT
  # use `dbus-run-session`: it spawns a throwaway bus isolated from that keyring,
  # so every secret access spawns a second, LOCKED keyring daemon and pops the
  # "login keyring did not get unlocked" prompt (diagnosed 2026-07-15).
  #
  # An inline `--cmd "DBUS_...=unix:path=$XDG_RUNTIME_DIR/bus sway ..."` was tried
  # first and broke login into an infinite greeter loop, because greetd's shell
  # (a) did not treat the leading `VAR=value` as an env assignment and tried to
  # exec it as a path, and (b) expanded `$XDG_RUNTIME_DIR` in the *greeter's*
  # context (uid 991) instead of the user's. A wrapper script sidesteps both:
  # it is an opaque path to greetd, and `$UID` (a bash builtin, the real uid of
  # the user actually running the session) is expanded here at runtime, so the
  # bus path is always /run/user/<the-user>/bus. The user bus socket is created
  # by pam_systemd before this runs.
  swaySession = pkgs.writeShellScript "sway-session" ''
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"
    exec sway --unsupported-gpu > /tmp/sway.log 2>&1
  '';
in

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
      # The actual session setup (D-Bus bus, sway exec) lives in the
      # `swaySession` wrapper above; see that comment for the full rationale.
      default_session.command = ''${pkgs-stable.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd "${swaySession}"'';
    };
  };
}
