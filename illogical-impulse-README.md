# illogical-impulse Hyprland Desktop Environment

This overlay provides comprehensive support for the illogical-impulse Hyprland desktop environment configuration, a Material Design 3-inspired UI with integrated widgets, themes, and system configurations.

## Package Structure

### Total: 30 Packages

#### From GURU Overlay (15 packages - imported to nekochigura)
- `app-misc/brightnessctl` - Screen brightness control
- `app-misc/cliphist` - Wayland clipboard manager
- `gui-apps/fuzzel` - Application launcher
- `gui-apps/hypridle` - Idle daemon
- `gui-apps/hyprlock` - Screen locker
- `gui-apps/hyprpicker` - Color picker
- `gui-apps/hyprshot` - Screenshot tool
- `gui-apps/hyprsunset` - Blue-light filter
- `gui-apps/wlogout` - Logout menu
- `gui-apps/wtype` - xdotool type for Wayland
- `gui-libs/xdg-desktop-portal-hyprland` - XDG Desktop Portal backend
- `media-fonts/twemoji` - Twitter emoji font
- `x11-misc/matugen` - Material You color generator
- `x11-themes/adw-gtk3` - Adwaita GTK3 theme

#### Custom Standalone Packages (11 packages)

**Fonts (4)**:
- `media-fonts/material-symbols-variable` - Material Design icons font
- `media-fonts/readex-pro` - Readex Pro font family
- `media-fonts/rubik-vf` - Rubik variable font
- `media-fonts/space-grotesk` - Space Grotesk font

**Themes (3)**:
- `kde-plasma/breeze-plus` - Enhanced Breeze icon theme
- `x11-themes/darkly` - Qt6 theme (Lightly fork)
- `x11-themes/oneui4-icons` - Samsung OneUI icon theme

**Widgets & Utilities (4)**:
- `app-misc/songrec` - Shazam-like song recognition
- `x11-misc/bibata-modern-classic` - Material Design cursor theme
- `dev-tex/microtex` - LaTeX rendering library
- `gui-apps/quickshell` - Qt6-based widget toolkit (live ebuild)

#### Metapackages (16 packages in app-misc/)

**Master Metapackage**:
- `illogical-impulse` - Install everything with one command

**Functional Metapackages**:
- `illogical-impulse-audio` - Audio utilities (cava, pavucontrol-qt, wireplumber, playerctl)
- `illogical-impulse-backlight` - Brightness control (geoclue, brightnessctl, ddcutil)
- `illogical-impulse-basic` - Core utilities (bc, cliphist, cmake, curl, wget, ripgrep, jq, yq-go)
- `illogical-impulse-fonts-themes` - Fonts and themes
- `illogical-impulse-hyprland` - Hyprland compositor and tools
- `illogical-impulse-kde` - KDE Plasma integration (bluedevil, plasma-nm, dolphin, systemsettings)
- `illogical-impulse-portal` - XDG Desktop Portal implementations
- `illogical-impulse-python` - Python development stack
- `illogical-impulse-screencapture` - Screenshot/recording tools (slurp, swappy, tesseract, wf-recorder)
- `illogical-impulse-toolkit` - System control tools (upower, wtype, ydotool)
- `illogical-impulse-widgets` - Widget dependencies

**Wrapper Metapackages** (for standalone packages):
- `illogical-impulse-bibata-modern-classic-bin` → `x11-misc/bibata-modern-classic`
- `illogical-impulse-oneui4-icons-git` → `x11-themes/oneui4-icons`
- `illogical-impulse-microtex-git` → `dev-tex/microtex`
- `illogical-impulse-quickshell-git` → `gui-apps/quickshell`

## Installation

### Quick Start (Install Everything)

```bash
emerge -av app-misc/illogical-impulse
```

### Prerequisites

#### hyproverlay Repository (Required)

Upstream now uses the `hyproverlay` overlay for Hyprland and related packages (hyprland >= 0.53.3, aquamarine, hyprgraphics, hyprutils, hyprwire, hyprtoolkit, hyprland-guiutils, glaze).

```bash
eselect repository enable hyproverlay
emerge --sync
```

#### Dependencies from Official Gentoo Repositories

Most dependencies (~60+ packages) are available in official Gentoo repositories. Key packages include:
- Audio: cava, pavucontrol-qt, wireplumber, playerctl
- Backlight: geoclue, brightnessctl, ddcutil
- Hyprland: hyprland (from hyproverlay), hyprsunset, wl-clipboard
- KDE: bluedevil, plasma-nm, dolphin, systemsettings
- Qt6: Complete Qt6 framework (qtbase, qtsvg, qt5compat, qtimageformats, qtmultimedia, etc.)
- Portal: xdg-desktop-portal, xdg-desktop-portal-kde, xdg-desktop-portal-gtk, xdg-desktop-portal-hyprland

### Overlay Priority (Important!)

To ensure nekochigura packages are preferred over GURU, set overlay priority in `/etc/portage/repos.conf/nekochigura.conf`:

```ini
[nekochigura]
location = /home/czl/nekochigura
priority = 100
```

Then run: `emerge --regen`

### Installation Order (Manual Installation)

**Tier 1: Fonts** (no dependencies):
```bash
emerge -av media-fonts/material-symbols-variable
emerge -av media-fonts/readex-pro
emerge -av media-fonts/rubik-vf
emerge -av media-fonts/space-grotesk
emerge -av media-fonts/twemoji
```

**Tier 2: Themes** (depend on KDE/Qt from official repos):
```bash
emerge -av kde-plasma/breeze-plus
emerge -av x11-themes/darkly
emerge -av x11-themes/adw-gtk3
emerge -av x11-themes/oneui4-icons
```

**Tier 3: Widgets**:
```bash
emerge -av app-misc/songrec
```

**Tier 4: Complex Special Packages**:
```bash
emerge -av x11-misc/bibata-modern-classic
emerge -av dev-tex/microtex
emerge -av gui-apps/quickshell
```

**Tier 5: Metapackages**:
```bash
emerge -av app-misc/illogical-impulse-basic
emerge -av app-misc/illogical-impulse-fonts-themes
emerge -av app-misc/illogical-impulse-hyprland
# ... install others as needed
```

## Post-Install Verification

### Fonts
```bash
fc-list | grep -i "material\|readex\|rubik\|space grotesk\|twemoji"
```

### Themes
```bash
ls /usr/share/themes/
ls /usr/share/icons/
```

### Quickshell
```bash
quickshell --version
```

### Cursors
```bash
ls ~/.icons/ /usr/share/icons/ | grep -i bibata
```

## Known Issues from Upstream

1. **Hyprland blank screen**: If widgets don't appear, rebuild Quickshell:
   ```bash
   emerge -av gui-apps/quickshell
   ```

2. **Hyprland shared library errors**: `error while loading shared libraries: libhyprgraphics.so.0`
   - Delete hyprland binaries from `/usr/bin/` and re-emerge:
   ```bash
   rm /usr/bin/Hyprland /usr/bin/hyprland
   emerge -av gui-wm/hyprland
   ```

3. **Hyprutils build errors**: `undefined reference to Hyprutils::Math::Vector2D::~Vector2D()`
   - Clear the portage cache and rebuild:
   ```bash
   rm -fr /var/tmp/portage/gui-wm/hyprland*
   emerge -av gui-wm/hyprland
   ```

4. **Quickshell stability**: May need rebuilding after Hyprland updates

## Session Requirements

- Session manager: elogind or systemd
- D-Bus daemon running
- Pipewire for audio

## Overlay Design

**External Overlay Dependency**: The `hyproverlay` overlay is required for Hyprland core packages (>=0.53.3). GURU packages were imported into nekochigura to avoid requiring the GURU overlay.

## Package Sources

- **Upstream**: https://github.com/end-4/dots-hyprland
- **Gentoo Distribution Files**: `/home/czl/experimental/dots-hyprland/sdata/dist-gentoo/`
- **GURU Imports**: Imported from https://gitweb.gentoo.org/repo/proj/guru.git

## Maintenance Notes

- All ebuilds use copyright: `# Copyright 2026 Chua Zheng Leong`
- EAPI 8 standard
- Tab indentation
- Manifests generated with `pkgdev manifest`
- Linted with `pkgcheck scan`

## pkgcheck Scan Results

Scan completed with minor warnings:
- Some packages have empty HOMEPAGE (cosmetic)
- Some packages show RedundantVersion (older versions available)
- Some dependencies unavailable in certain profiles (arm64, x86)
- All critical functionality intact for amd64

## License

Metapackages: metapackage
Individual packages: See respective LICENSE in each ebuild

## Support

For issues specific to this overlay, report to: nekochigura overlay maintainer
For upstream illogical-impulse issues: https://github.com/end-4/dots-hyprland/issues
