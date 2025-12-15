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
     default_session.command = ''
      ${pkgs-stable.tuigreet}/bin/tuigreet \
        --time \
        --asterisks \
        --user-menu \
        --cmd "dbus-run-session sway --unsupported-gpu > /tmp/sway.log 2>&1" \
    '';
    };
  };
}