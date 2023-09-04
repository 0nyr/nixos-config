# flake.nix for /etc/nixos/
{
  description = "Custom 0nyr's NixOS configuration";

  inputs = {
    # Official NixOS package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Minecraft grub2 theme
    #minegrub-theme.url = "github:Lxtharia/minegrub-theme"; # official repo
    minegrub-theme.url = "github:ocfox/minegrub-theme"; 
  };

  outputs = {nixpkgs, ...} @ inputs: {
    # replace whatever comes after nixosConfigurations with your hostname.
    # My laptop configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        inputs.minegrub-theme.nixosModules.default
      ];
    };
  };
}
