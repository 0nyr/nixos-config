# flake.nix for /etc/nixos/
{
  description = "Multi-system custom 0nyr's NixOS configuration";

  inputs = {
    # Official NixOS package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Nixos Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    # Minecraft grub2 theme
    #minegrub-theme.url = "github:Lxtharia/minegrub-theme"; # official repo
    #minegrub-theme.url = "github:ocfox/minegrub-theme"; # alternative older fork
    minegrub-theme.url = "github:0nyr/minegrub-theme"; # my fork with some fixes
  };

  outputs = {nixpkgs, ...} @ inputs: 
  let
    system = "x86_64-linux";
    #       ↑ Swap it for your system if needed
    #       "aarch64-linux" / "x86_64-darwin" / "aarch64-darwin"
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Machine-based system configurations
    nixosConfigurations = {
      "Aezyr-Workstation" = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs.inputs = inputs;
        modules = [ ./hosts/aezyr/configuration.nix ];
      };
      "Kenzae-Laptop" = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs.inputs = inputs;
        modules = [ ./hosts/kenzae/configuration.nix ];
      };
    };

    # development shell
    devShells.${system}.default = pkgs.mkShell {
      TEST_ENV_VAR = "Hello, world!";
    };
  };
}
