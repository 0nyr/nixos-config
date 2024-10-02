# flake.nix for /etc/nixos/
{
  description = "Custom 0nyr's NixOS configuration";

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
    # replace whatever comes after nixosConfigurations with your hostname.
    # My laptop configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        ./configuration.nix
        inputs.minegrub-theme.nixosModules.default
        # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        inputs.nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
        # other modules
        #({...}: {
        #  nixpkgs.config.packageOverrides = pkgs: {
        #    vscode = pkgs.vscode.overrideAttrs (old: {
        #      version = "1.82.1";
        #      # You might need to set other attributes like src as well
        #    });
        #  };
        #})
      ];
    };

    # development shell
    devShells.${system}.default = pkgs.mkShell {
      TEST_ENV_VAR = "Hello, world!";
    };
  };
}
