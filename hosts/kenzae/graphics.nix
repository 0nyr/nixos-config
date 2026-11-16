# Graphics specifics of Kenzae (TUXEDO InfinityBook Pro Gen7, hybrid GPU).
#
#   00:02.0  Intel Iris Xe (i915)        eDP-1 (panel), DP-1, DP-2 (USB-C)
#   01:00.0  NVIDIA RTX 3070 Ti (nvidia) HDMI-A-1, DP-3
#
# The desktop renders on the Intel GPU. The generic NVIDIA driver setup lives
# in modules/nvidia.nix. This file adds the Intel video acceleration and the
# opt-in boot entries that let the NVIDIA GPU power down when idle.
{ config, pkgs, lib, ... }:

let
  # PRIME render offload with runtime power management (RTD3). The NVIDIA GPU
  # powers down when idle and only runs the programs started with
  # `nvidia-offload <cmd>`.
  nvidiaOffload = {
    hardware.nvidia = {
      powerManagement.enable = lib.mkForce true; # required by finegrained
      powerManagement.finegrained = lib.mkForce true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true; # provides `nvidia-offload`
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
in
{
  # Hardware video decode and encode on the Intel GPU (VA-API). Without it,
  # browsers encode video calls and screen sharing on the CPU.
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  environment.systemPackages = [ pkgs.libva-utils ]; # provides `vainfo`

  # Stable name for the Intel DRM card. card0 and card1 can swap between
  # boots, and the by-path name contains ":", the separator of WLR_DRM_DEVICES.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor", KERNEL=="card[0-9]*", KERNELS=="0000:00:02.0", SYMLINK+="dri/igpu"
  '';

  # Experimental boot entries, picked by hand in the systemd-boot menu. The
  # default entry keeps the NVIDIA GPU always on, as before.
  specialisation = {
    # Sway still opens both GPUs, so HDMI-A-1 and DP-3 stay available. An open
    # DRM card may prevent the NVIDIA GPU from reaching runtime suspend.
    nvidia-offload.configuration = lib.mkMerge [
      nvidiaOffload
      { system.nixos.tags = [ "nvidia-offload" ]; }
    ];

    # Same, and sway only opens the Intel GPU. The NVIDIA GPU is then free to
    # suspend, but the outputs wired to it (HDMI-A-1, DP-3) are unavailable.
    nvidia-offload-igpu-only.configuration = lib.mkMerge [
      nvidiaOffload
      {
        system.nixos.tags = [ "nvidia-offload-igpu-only" ];
        environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/igpu";
      }
    ];
  };
}
