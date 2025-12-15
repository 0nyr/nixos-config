{ config, pkgs, pkgs-stable, lib, ... }:

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

  hardware.graphics = {
    enable = true; # OpenGL (new name for hardware.opengl.enable)
    enable32Bit = true; # On 64-bit systems, whether to also install 32-bit drivers for 32-bit applications (such as Wine).
  };

  # LLMs and AI models (Need Nvidia)
  # services.ollama = {
  #   enable = true;
  #   acceleration = "cuda";
  # }; # Build failed...
  # services.open-webui = {
  #   enable = true;
  # }; # worked but now fails
}