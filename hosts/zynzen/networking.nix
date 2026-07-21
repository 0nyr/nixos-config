# Networking for zynzen (OVH VPS).
# IPv4 54.37.9.207/32 with an OFF-LINK default gateway 54.37.8.1 (not inside the /32).
# The scripted dhcpcd path can fail to install the default route for an off-link gateway
# (nixos-images #242) and leave the box reachable-by-IP-but-unroutable after a reinstall.
# Mirror the working Ubuntu (netplan -> networkd): systemd-networkd + GatewayOnLink=true.
{ ... }:
{
  networking.useDHCP = false;
  networking.useNetworkd = true;

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "en*";              # single NIC; avoids the ens3-vs-other-name gamble
    address = [ "54.37.9.207/32" ];
    routes = [
      { Gateway = "54.37.8.1"; GatewayOnLink = true; }  # off-link gateway forced on-link
    ];
    networkConfig.DHCP = "no";
    linkConfig.RequiredForOnline = "routable";
  };

  # Defer IPv6 (no AAAA yet). Do NOT set networking.defaultGateway6 while deferring
  # (nixpkgs #178078: a v6 gateway can clobber the v4 default gateway).
  networking.enableIPv6 = false;
}
