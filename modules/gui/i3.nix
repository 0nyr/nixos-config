{ config, pkgs, lib, ... }:

{
  # Use i3 on top of Gnome
  services.xserver = {
    windowManager.i3.enable = true;
  };

  services.xserver.windowManager.i3.extraPackages = with pkgs; [
    # i3 specific packages
    i3status
    dmenu
    (polybar.override { pulseSupport = true; i3Support = true; })
    bc
    shutter # screenshot
    flameshot # screenshot
    rofi # application launcher menu
    xss-lock # screen saver
    i3lock-color
    feh # wallpaper
    xorg.xrandr # for dual screen
    arandr # GUI for xrandr
  ];
}