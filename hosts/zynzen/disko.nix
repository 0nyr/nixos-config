# Disk layout for zynzen (OVH VPS). Legacy BIOS boot on /dev/sda (virtio-scsi; no /dev/vda).
# GPT: 1M BIOS-boot (EF02) + 2G swap + ext4 root. No separate /boot and no ESP on BIOS.
# nixos-anywhere runs disko in destroy+format mode, wiping the pre-existing Ubuntu GPT.
{ lib, ... }:
{
  disko.devices.disk.main = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";        # GPT BIOS-boot partition (holds GRUB core.img)
          attributes = [ 0 ];   # matches disko's upstream gpt-bios-compat example
        };
        swap = {
          size = "2G";
          content = { type = "swap"; };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  # Legacy BIOS: GRUB embeds core.img in the EF02 partition and reads /boot from the ext4 root.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    # disko may also derive this from the EF02 partition's parent disk; mkDefault avoids a clash.
    devices = lib.mkDefault [ "/dev/sda" ];
  };
}
