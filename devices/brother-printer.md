# Brother HL-L2300D Printer Setup

## Configuration

The Brother HL-L2300D laser printer is configured as a network IPP (Internet Printing Protocol) printer, shared from another machine on the network. It uses Avahi (mDNS) for local hostname resolution to enable proper configuration overrides.

The configuration is in `devices/brother-printer.nix`:

```nix
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
```

## How It Works

### Avahi/mDNS for Hostname Resolution

The configuration uses Avahi to enable mDNS (Multicast DNS) support, which allows the NixOS machine to resolve `.local` hostnames on the local network. This is important for printer configuration because:

- **`services.avahi.enable = true`**: Enables mDNS responder
- **`services.avahi.nssmdns4 = true`**: Integrates mDNS with the system's hostname resolver
- **`services.avahi.openFirewall = true`**: Allows mDNS traffic through the firewall
- **`services.printing.browsed.enable = false`**: Disables CUPS browsing to prevent configuration conflicts with the print server

The `.local` hostname (`ubuntu.local`) allows the printer's PPD options to be properly applied locally, overriding any defaults set on the print server (such as single vs. double-sided printing).

### Network Printing via IPP

The printer is physically connected to a machine named `ubuntu` on your local network, which shares it via CUPS (Common Unix Printing System) using the IPP protocol.

**Key configuration elements:**

- **`deviceUri`**: `ipp://ubuntu.local/printers/Brother_HL-L2300D_series`
  - Points to the CUPS server on the `ubuntu` machine using mDNS hostname resolution
  - Uses standard IPP protocol (port 631)
  
- **`model`**: `drv:///sample.drv/generic.ppd`
  - Uses the generic PostScript printer driver
  - Works for most modern laser printers that support PostScript
  
- **`ppdOptions.PageSize`**: `"Letter"`
  - Sets default paper size to Letter (US standard)
  - Change to `"A4"` if you use European A4 size

### Declarative Printer Management

NixOS's `hardware.printers.ensurePrinters` ensures the printer configuration is:
- **Declarative**: Defined in configuration.nix, version controlled
- **Idempotent**: Same configuration produces same result every time
- **Persistent**: Survives system rebuilds and reboots

The `ensureDefaultPrinter` option sets this as the system default printer automatically.

## Testing

```bash
# List available printers
lpstat -p -d

# Print a test page
echo "Test print from NixOS" | lp -d Brother_HL-L2300D

# Check printer status
lpstat -p Brother_HL-L2300D

# View print queue
lpq -P Brother_HL-L2300D
```

## Troubleshooting

### Printer not responding

1. **Check network connectivity to the print server:**
   ```bash
   ping ubuntu
   ```

2. **Verify IPP service is accessible:**
   ```bash
   curl http://ubuntu:631/printers/Brother_HL-L2300D_series
   ```

3. **Check CUPS status:**
   ```bash
   systemctl status cups
   ```

### Print jobs stuck in queue

```bash
# Cancel all jobs for this printer
cancel -a Brother_HL-L2300D

# Restart CUPS service
sudo systemctl restart cups
```

### Change paper size

Edit `devices/brother-printer.nix` and change the `PageSize` option:
```nix
ppdOptions = {
  PageSize = "A4";  # or "Letter", "Legal", etc.
};
```

Then rebuild: `sudo nixos-rebuild switch --flake .#imac`

## Network Requirements

- The `ubuntu` machine must be:
  - Running CUPS with network sharing enabled
  - Reachable on your local network
  - Configured to share the Brother_HL-L2300D_series printer
  
- No firewall configuration needed on the NixOS machine (outbound connections only)

## Notes

- This is a **network printer setup**, not a directly connected USB printer
- The printer driver runs on the print server (`ubuntu`), not on this NixOS machine
- If the `ubuntu` machine is offline, printing will fail
- For USB-connected printing directly to this NixOS machine, you would need to install Brother's proprietary drivers
