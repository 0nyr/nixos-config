# See: https://www.drakerossman.com/blog/wayland-on-nixos-confusion-conquest-triumph#display-server
{
  pkgs, ...
}:

{
  services.greetd = {
    enable = true;
    settings = {
     default_session.command = ''
      ${pkgs.greetd.tuigreet}/bin/tuigreet \
        --time \
        --asterisks \
        --user-menu \
        --cmd "dbus-run-session sway --unsupported-gpu" \
    '';
    };
  };

  # Ensure that the greetd service has access to sway
  environment.systemPackages = with pkgs; [
    greetd.tuigreet
    sway
  ];
}