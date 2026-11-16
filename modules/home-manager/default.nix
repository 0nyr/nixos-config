# User-level Home Manager entrypoint for `onyr`.
#
# Kept minimal for the Kenzae-first rollout: it only enables HM and pulls in the
# dotagents symlink map. Aezyr still uses the older modules/home.nix. Unifying both hosts onto this
# module is a deliberate follow-up.
{ config, pkgs, pkgs-stable, inputs, lib, ... }:
{
  imports = [
    ./agents.nix
  ];

  programs.home-manager.enable = true;

  systemd.user.services.codex-remote-control = {
    Unit = {
      Description = "Codex remote control";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "/home/onyr/.local/bin/codex remote-control start";
      ExecStop = "/home/onyr/.local/bin/codex remote-control stop";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "default.target" ];
  };

  home = {
    username = "onyr";
    homeDirectory = "/home/onyr";
    stateVersion = "25.05";
  };
}
