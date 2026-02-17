# Brother HL-L2300D — Network Printer
# Shared via IPP from a machine named "ubuntu" on the local network.
{...}: {
  services.printing.enable = true;

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_HL-L2300D";
        location = "Loft";
        deviceUri = "ipp://ubuntu/printers/Brother_HL-L2300D_series";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_HL-L2300D";
  };
}
