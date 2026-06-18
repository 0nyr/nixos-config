# NixOS module: enable Home Manager and wire user `onyr`.
#
# Self-contained on purpose (Kenzae-first rollout): it imports the Home Manager
# NixOS module and sets the common HM defaults itself, so a host gets full HM by
# importing just this file. Do NOT also import it on a host whose base already
# brings HM in (e.g. Aezyr via modules/configuration.nix) without first removing
# that host's HM wiring — defining home-manager.extraSpecialArgs / users.onyr in
# two places is an eval conflict. See ~/.agents/README.md.
{ inputs, pkgs-stable, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs-stable; };
    # Back up (rather than fail on) any pre-existing target file the first time
    # HM takes ownership of a path.
    backupFileExtension = "hm-bak";
    users.onyr = import ./home-manager/default.nix;
  };
}
