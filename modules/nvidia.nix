{ config, pkgs, lib, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true; # Modesetting is needed for most Wayland compositors
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true; # Enable the nvidia settings menu
    # Video card specific - stable supports "newer" cards, production for 535 drivers
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # LLMs and AI models (Need Nvidia)
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  services.open-webui = {
    enable = true;
  }
}