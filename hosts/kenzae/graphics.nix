# Graphics specifics of Kenzae (TUXEDO InfinityBook Pro Gen7, hybrid GPU).
#
#   00:02.0  Intel Iris Xe (i915)        eDP-1 (panel), DP-1, DP-2 (USB-C)
#   01:00.0  NVIDIA RTX 3070 Ti (nvidia) HDMI-A-1, DP-3
#
# The desktop renders on the Intel GPU. The generic NVIDIA driver setup lives
# in modules/nvidia.nix. With driver 595.112 and sway 1.12 the NVIDIA GPU
# already powers down when idle (runtime D3, checked 2026-11-16 through
# /sys/bus/pci/devices/0000:01:00.0/power/runtime_status), so no PRIME or
# power-management option is set here.
{ config, pkgs, lib, ... }:

let
  # Run one program on the NVIDIA GPU: `nvidia-offload <cmd>`. Same variables
  # as the wrapper of `hardware.nvidia.prime.offload.enableOffloadCmd`, without
  # enabling the PRIME module.
  nvidiaOffload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  # Hardware video decode and encode on the Intel GPU (VA-API). Without it,
  # browsers encode video calls and screen sharing on the CPU.
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  environment.systemPackages = [
    pkgs.libva-utils # provides `vainfo`
    nvidiaOffload
  ];

  # Hide the HDMI/DP audio device of the NVIDIA card from PipeWire. When the
  # USB-C headphone adapter is unplugged, WirePlumber picks this device as
  # the default output, and any stream played into it keeps the audio
  # function 01:00.1 awake, which keeps the whole NVIDIA GPU awake (found on
  # 2026-11-17). A rule that only sets the profile to "off" is not enough,
  # because a profile stored in ~/.local/state/wireplumber wins over it.
  # Consequence: no sound through a screen plugged on HDMI-A-1 or DP-3.
  # Remove this block and rebuild to get it back.
  services.pipewire.wireplumber.extraConfig."51-kenzae-no-nvidia-hdmi-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "device.name" = "alsa_card.pci-0000_01_00.1"; } ];
        actions.update-props."device.disabled" = true;
      }
    ];
  };
}
