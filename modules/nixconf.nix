# This file contains the Nix options
# See https://nix.dev/manual/nix/2.25/command-ref/conf-file.html 
# It is used to generate the /etc/nix/nix.conf file.

{ config, pkgs, lib, ... }:

{
  nix = {
    settings = {
      # Increase Nix's internal download buffer size during curl transfers.
      # See [GitHub issue](https://github.com/NixOS/nix/issues/11728)
      # See [the doc](https://nix.dev/manual/nix/2.25/command-ref/conf-file.html#conf-download-buffer-size)
      # WARNING: Hyphenated (-) keys must be quoted
      "download-buffer-size" = 1073741824; # 1 Gib
    };
  };
}