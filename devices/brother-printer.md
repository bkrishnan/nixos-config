# Brother HL-L2300D Printer Setup

## Configuration

The Brother HL-L2300D laser printer is configured as a network IPP (Internet Printing Protocol) printer, shared from another machine on the network.

Add this to `configuration.nix`:

```nix
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
```

## How It Works

### Network Printing via IPP

The printer is physically connected to a machine named `ubuntu` on your local network, which shares it via CUPS (Common Unix Printing System) using the IPP protocol.

**Key configuration elements:**

- **`deviceUri`**: `ipp://ubuntu/printers/Brother_HL-L2300D_series`
  - Points to the CUPS server on the `ubuntu` machine
  - Uses standard IPP protocol (port 631)
  
- **`model`**: `drv:///sample.drv/generic.ppd`
  - Uses the generic PostScript printer driver
  - Works for most modern laser printers that support PostScript
  
- **`ppdOptions.PageSize`**: `"A4"`
  - Sets default paper size to A4 (European standard)
  - Change to `"Letter"` if you use US Letter size

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

Edit `configuration.nix` and change the `PageSize` option:
```nix
ppdOptions = {
  PageSize = "Letter";  # or "A4", "Legal", etc.
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
