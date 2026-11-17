# Local LLM on Kenzae, an offline backup for everyday IT help.
# Notes and decisions: phd_note_vault/docs/AILOGS/2026-11-16-local-llm-1.md
{ config, pkgs, lib, ... }:

{
  # Binary cache of the NixOS CUDA team. The CUDA builds of nixpkgs (unfree)
  # are not on cache.nixos.org, and without this cache the first rebuild that
  # asks for llama-cpp-cuda compiles the whole CUDA stack. It must be active in
  # /etc/nix/nix.conf (one rebuild) before any CUDA package is requested.
  # URL and key from https://wiki.nixos.org/wiki/CUDA (checked 2026-11-17).
  nix.settings = {
    extra-substituters = [ "https://cache.nixos-cuda.org" ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}
