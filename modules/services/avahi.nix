# Avahi — mDNS / .local hostname resolution.
# denyInterfaces excludes tailscale0: that interface doesn't support multicast,
# and avahi-daemon will crash trying to join 224.0.0.251 on it, breaking .local
# resolution for the whole machine.
{...}: {
  services.avahi = {
    enable = true;
    nssmdns4 = true; # enables nss-mdns IPv4 NSS module for .local lookups
    openFirewall = true;
    denyInterfaces = ["tailscale0"];
    publish = {
      enable = true;
      addresses = true; # announce this host's IP so others can resolve <hostname>.local
    };
  };
}
