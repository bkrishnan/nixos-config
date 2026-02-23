# Brother HL-L2300D — Network Printer
# Shared via IPP from a machine named "ubuntu" on the local network.
{...}: {
  services.printing.enable = true;
  services.printing.browsed.enable = false;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_HL-L2300D";
        location = "Loft";
        deviceUri = "ipp://ubuntu.local/printers/Brother_HL-L2300D_series";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_HL-L2300D";
  };
}
