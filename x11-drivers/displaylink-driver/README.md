# DisplayLink USB Graphics Software Driver

This ebuild packages the DisplayLink USB Graphics Software userspace daemon for Gentoo Linux.

## Architecture Support

- **AMD64** (x86_64)
- **ARM64** (aarch64) - including Raspberry Pi 4 and other ARM64 devices

## Prerequisites

1. The EVDI kernel module must be installed:
   ```bash
   emerge x11-drivers/evdi
   ```

2. Accept the DisplayLink proprietary license by adding to `/etc/portage/make.conf`:
   ```bash
   ACCEPT_LICENSE="DisplayLink"
   ```

## Installation

```bash
emerge -av x11-drivers/displaylink-driver
```

## Usage

1. Load the EVDI kernel module:
   ```bash
   modprobe evdi
   ```

2. Enable and start the DisplayLink service:
   ```bash
   systemctl enable --now displaylink-driver.service
   ```

3. Connect your DisplayLink device

## Display Configuration

### X11 Configuration

Configure displays using xrandr:

```bash
# List all display providers
xrandr --listproviders

# Connect DisplayLink provider to primary GPU
# Replace provider numbers as shown in listproviders output
xrandr --setprovideroutputsource 1 0

# List all available outputs
xrandr

# Configure DisplayLink monitor
xrandr --output DVI-1-0 --auto --right-of eDP-1
```

### Wayland Configuration

DisplayLink works with Wayland compositors through DRM output management.

#### GNOME (Mutter)

DisplayLink monitors should appear automatically in Settings → Displays once the service is running. No additional configuration needed.

#### KDE Plasma (KWin)

1. Ensure the DisplayLink service is running
2. Open System Settings → Display Configuration
3. DisplayLink monitors should appear and can be configured graphically

#### Sway (wlroots)

List available outputs:
```bash
swaymsg -t get_outputs
```

Configure in `~/.config/sway/config`:
```
# Example: Configure DisplayLink monitor
output DP-1 mode 1920x1080@60Hz position 1920,0
output DP-2 mode 2560x1440@60Hz position 0,0
```

Use `wlr-randr` for runtime configuration:
```bash
# List outputs
wlr-randr

# Configure DisplayLink output
wlr-randr --output DP-1 --mode 1920x1080@60Hz --pos 1920,0
```

#### Hyprland

Configure in `~/.config/hypr/hyprland.conf`:
```
# Example: Configure DisplayLink monitor
monitor=DP-1,1920x1080@60,1920x0,1
monitor=eDP-1,1920x1080@60,0x0,1
```

#### Other wlroots-based compositors

Most wlroots compositors support similar output configuration. Refer to your compositor's documentation for output management.

**Note:** Some Wayland compositors may require restarting after connecting a DisplayLink device for proper detection.

## Troubleshooting

### Check Service Status

```bash
systemctl status displaylink-driver.service
journalctl -u displaylink-driver.service
dmesg | grep -i displaylink
```

### Verify EVDI Module

```bash
lsmod | grep evdi
```

If not loaded:
```bash
modprobe evdi
```

### Display Not Detected

1. Restart the DisplayLink service:
   ```bash
   systemctl restart displaylink-driver.service
   ```

2. For Wayland, restart your compositor or session

3. Check USB device is detected:
   ```bash
   lsusb | grep -i displaylink
   ```

### Performance Issues

- Enable hardware acceleration in your compositor
- Reduce resolution or refresh rate on DisplayLink monitor
- Check for USB 3.0 connection (USB 2.0 has limited bandwidth)

## More Information

- **Official DisplayLink Downloads:** https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu
- **DisplayLink Support:** https://support.displaylink.com
- **EVDI GitHub:** https://github.com/DisplayLink/evdi
- **ARM64 Support:** Tested on Raspberry Pi 4 and other ARM64 devices
