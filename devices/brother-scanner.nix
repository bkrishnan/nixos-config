# Brother MFC-J410W — Network Scanner
# Uses brscan4 driver (NOT brscan3, despite the device being older — see docs/README.md)
{...}: {
  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "MFC-J410W";
          # mDNS nodename — more reliable than a DHCP IP address
          nodename = "BRW00225857670B";
        };
      };
    };
  };
}
