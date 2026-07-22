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

  # Reclaim space automatically if the OVH disk is ever resized larger (future flavor upgrade).
  # Growing a VPS disk only appends free space after the last partition (root, /dev/sda3), so the
  # existing partitions stay byte-identical. growPartition then extends the root partition to fill
  # the disk and autoResize grows the ext4 filesystem online. Both are no-ops when there is no free
  # space, hence safe to leave enabled permanently.
  # NOTE: these act on BOOT, not on `nixos-rebuild switch` — so an actual resize needs one reboot.
  boot.growPartition = true;
  fileSystems."/".autoResize = true;
}
