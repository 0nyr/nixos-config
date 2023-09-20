# My NixOS config files

This repository contain my personal NixOS configuration.

This configuration expects that dotfiles are setup for user `onyr`. See [my dotfiles config repo](https://github.com/0nyr/dotfiles) for those dotfiles. I prefered to do so, since I want to reuse those dotfiles on other distros as well.

Flake is used to make reproducible environnement.

## ❄ NixOS commands

`nix-env --list-generations --profile /nix/var/nix/profiles/system`: list nixos build generations.

#### updating packages

`nix flake update`: to update all inputs of the flake

`nix flake lock --update-input`: to update a single input of the flake

## 🌱 Setup

To enable this repo to be the new config for NixOS, add a symlink to `/etc/` like so:

```shell
ln -s /home/onyr/nixos-config/ nixos
```

Then rebuild with `nixos-rebuild switch`.
