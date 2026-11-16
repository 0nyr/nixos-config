{ config, pkgs, pkgs-stable, lib, ...}:

{
  # sound related packages - use stable for rock-solid audio utilities
  environment.systemPackages = with pkgs-stable; [
    pavucontrol # for advanced sound control
    alsa-utils # for alsamixer
    qpwgraph # for visualizing PipeWire graph, equivalent to what qjackctl is to JACK
    pciutils # for PCI utilities (like listing audio cards)
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false; # pulseaudio must be disabled when using pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true; # Wireplumber as session manager for Pipewire
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # JACK emulation stays off: the option is deprecated upstream because it
    # injects a global LD_LIBRARY_PATH. Use the `pw-jack` wrapper if ever needed.

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
}