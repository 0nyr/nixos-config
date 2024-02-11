# My NixOS config files

This repository contain my personal NixOS configuration.

This configuration expects that dotfiles are setup for user `onyr`. See [my dotfiles config repo](https://github.com/0nyr/dotfiles) for those dotfiles. I prefered to do so, since I want to reuse those dotfiles on other distros as well.

Flake is used to make reproducible environnement.

## ❄ NixOS commands

#### managing generations

`nix-env --list-generations --profile /nix/var/nix/profiles/system`: list nixos build generations.

`nix-env --delete-generations 34 --profile /nix/var/nix/profiles/system`: delete generation 34

`nix-collect-garbage -d`: run garbage collector to free up space

#### updating packages

`nix flake update`: to update all inputs of the flake

`nix flake lock --update-input`: to update a single input of the flake

#### Building the system

`nixos-rebuild build`: build the system without switching to it.

`nixos-rebuild build`: build the system without switching to it.

`nixos-rebuild --install-bootloader boot`: Reinstall the bootloader.

`systemctl reboot --firmware-setup`: Reboot into Firmware (BIOS-UEFI settings).

## 🌱 Setup

To enable this repo to be the new config for NixOS, add a symlink to `/etc/` like so:

```shell
ln -s /home/onyr/nixos-config/ nixos
```

Then rebuild with `nixos-rebuild switch`.
