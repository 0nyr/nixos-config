# My NixOS config files

This repository contains my personal NixOS configuration.

This configuration expects that dotfiles are set up for user `onyr`. See [my dotfiles config repo](https://github.com/0nyr/dotfiles) for those dotfiles. I preferred to do so, since I want to reuse those dotfiles on other distros as well. Yet I'm planning to transition to `home-manager` in the future.

Flake is used to make reproducible environment.

## ❄ NixOS commands

#### Managing generations

`nix-env --list-generations --profile /nix/var/nix/profiles/system`: list nixos build generations.
`nixos-rebuild list-generations`: also list nixos build generations.

`nix-env --delete-generations 34 --profile /nix/var/nix/profiles/system`: delete generation 34. Example below:

```
[root@nixos:/home/onyr/nixos-config]# nix-env --delete-generations 37 39 41 42 43 --profile /nix/var/nix/profiles/system
removing profile version 37
removing profile version 39
removing profile version 41
removing profile version 42
removing profile version 43
```

`nix-collect-garbage -d`: run garbage collector to free up space

#### Updating packages

`nix flake update`: to update all inputs of the flake

`nix flake lock --update-input`: to update a single input of the flake

#### (Re)-building the system

`sudo nixos-rebuild switch --flake .#Aezyr-Workstation`: rebuild Aezyr system.

`sudo nixos-rebuild switch --flake .#Kenzae-Laptop`: rebuild Aezyr system.

`nixos-rebuild build`: build the system without switching to it.

`nixos-rebuild --install-bootloader boot`: Reinstall the bootloader.

`systemctl reboot --firmware-setup`: Reboot into Firmware (BIOS-UEFI settings).

## 🌱 Setup

To enable this repo to be the new config for NixOS, add a symlink to `/etc/` like so:

```shell
ln -s /home/onyr/nixos-config/ nixos
```

Then rebuild with `nixos-rebuild switch` for a mono-system config, or `sudo nixos-rebuild switch --flake .#<CONGIG_NAME>` in a multi-system config.
