# Brother Scanner Setup - MFC-J410W

## ✅ SOLVED: Use brscan4, not brscan3!

### The Solution

The **MFC-J410W requires brscan4**, not brscan3. NixOS has built-in support for brscan4, so no custom module is needed!

## Configuration

Add this to `configuration.nix`:

```nix
hardware.sane = {
  enable = true;
  brscan4 = {
    enable = true;
    netDevices = {
      home = {
        model = "MFC-J410W";
        nodename = "BRW00225857670B";  # Or use: ip = "192.168.29.226";
      };
    };
  };
};
```

**Note**: Use either `nodename` (mDNS name) or `ip` (static IP), not both. The nodename is more reliable if your scanner's IP changes.

That's it! After `sudo nixos-rebuild switch`, the scanner works. No need for avahi services or firewall configuration - the brscan4 module handles everything automatically.

## Testing

```bash
# List scanners
scanimage -L
# Output: device `brother4:net1;dev0' is a Brother *home MFC-J410W

# Test scan
scanimage --device="brother4:net1;dev0" --format=png --output-file=test-scan.png

# Scan with specific resolution
scanimage --device="brother4:net1;dev0" --format=png --resolution 300 --output-file=scan-300dpi.png
```

## Lessons Learned

### Why brscan4 works (despite Arch using brscan3)

**The observation**: The [Arch AUR brscan3 package](https://aur.archlinux.org/packages/brscan3) lists the MFC-J410W, but [brscan4](https://aur.archlinux.org/packages/brscan4) does not.

**What's happening:**
1. **Brother's driver overlap**: Brother released the MFC-J410W during the brscan3 era, but the brscan4 driver is backward compatible with many brscan3 devices
2. **NixOS's brscan4 package**: The NixOS brscan4 package (version 0.4.10-1) is more recent than the version Arch uses for brscan3
3. **Driver maturity**: brscan4 has better support for network scanning and is more actively maintained

**Bottom line**: Even though the MFC-J410W was originally a brscan3 device, it works perfectly with brscan4 in NixOS. The brscan4 driver is essentially a superset that includes support for older models.

### Why This Works (and brscan3 Didn't)

1. **Wrong driver assumption**: The MFC-J410W is NOT a brscan3 device. Despite being an older printer, it requires the brscan4 driver.
   - Created custom brscan3 module following brscan4 pattern
   - Added `$out/etc/sane.d/dll.conf` to package (like brscan4 does)
   - Patched libusb dependencies with RPATH
   - brother3 backend loaded but crashed with SIGSEGV
   - Debug showed: MFC-J410W (0x4f9:0x255) not in Brsane3.ini supported models
   - Switched to brscan4: **immediate success**

3. **Key insight from Discourse thread**: The [NixOS Discourse thread](https://discourse.nixos.org/t/brother-dcp-l2530dw-network-scanner-on-nixos-brscan4-driver-issue/72626/3) showed users successfully using `hardware.sane.brscan4` module with simple configuration.

4. **Package structure**: Brother scanner packages must include:
   - `$out/etc/sane.d/dll.conf` with backend name
   - Proper RPATH patching for `libusb-compat-0_1`
   - Configuration files in `/etc/opt/brother/scanner/brscanX/`

## Troubleshooting

If scanner isn't detected:

```bash
# Check if backend is loaded
SANE_DEBUG_DLL=3 scanimage -L 2>&1 | grep brother

# Check network connectivity
ping 192.168.29.226

# Verify user is in scanner group
groups | grep scanner

# Check Brother config
cat /etc/opt/brother/scanner/brscan4/brsanenetdevice4.cfg
```
