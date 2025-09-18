{ config, pkgs, lib, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.onyr = {
    isNormalUser = true;
    description = "onyr";
    home = "/home/onyr";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" "storage" "video" "render" "vboxusers" ];
    packages = with pkgs; [
      # applications
      firefox
      brave
      vscode.fhs
      eclipses.eclipse-java 
      thunderbird # amazing email client
      zotero # reference manager for research
      discord # chat
      libreoffice # office suite, libre version of MS Office
      obsidian # note taking app
      pdfannots2json # command line utility for Obsidian (Zotero Integration plugin)
      krita # painting and image editing
      inkscape # vector graphics editor
      vlc # the famous media player
      tenacity # audio editor, fork of Audacity
      davinci-resolve # video editor
      blender # 3D modeling and video editing
      obs-studio # screen recording
      simplescreenrecorder # screen recording
      kooha # screen recording

      # games
      prismlauncher # For Minecraft
    ];
  };
}