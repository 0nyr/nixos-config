# flake.nix for /etc/nixos/
{
  description = "Multi-system custom 0nyr's NixOS configuration";

  inputs = {
    # Official NixOS package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Nixos Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Minecraft grub2 theme
    #minegrub-theme.url = "github:Lxtharia/minegrub-theme"; # official repo
    #minegrub-theme.url = "github:ocfox/minegrub-theme"; # alternative older fork
    minegrub-theme.url = "github:0nyr/minegrub-theme"; # my fork with some fixes

    # hy3 / hyperland
    # See https://github.com/hyprwm/Hyprland
    hyprland.url = "github:hyprwm/Hyprland?submodules=1&ref=v0.47.1";
    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.47.0-1"; # where {version} is the hyprland release version
      # or "github:outfoxxed/hy3" to follow the development branch.
      # (you may encounter issues if you dont do the same for hyprland)
      inputs.hyprland.follows = "hyprland";
    };
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
