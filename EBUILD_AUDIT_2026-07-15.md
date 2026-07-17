# Ebuild audit — 2026-07-15

This is the persistent ledger for the repository-wide ebuild audit performed on
2026-07-15. It is intended to be worked through one issue at a time. Before any
issue is changed, present a concrete proposal and wait for maintainer approval.

## Scope and method

- Audited 213 ebuilds in 91 package directories.
- Covered every package under `acct-*`, `app-*`, `dev-*`, `gui-*`,
  `kde-plasma`, `media-*`, `net-*`, `sci-*`, `sys-*`, and `x11-*`.
- Compared newest local versions/snapshots against official upstream release,
  tag, package-index, or commit sources as of 2026-07-15.
- Ran repository-wide `pkgcheck scan` and a network-backed scan. Network scan
  connection failures are not treated as proof of dead URLs.
- All ebuilds use EAPI 8; no EAPI failures were found.
- No build matrix has yet been completed. Findings are static review,
  dependency resolution, fetch reproducibility, and targeted metadata checks.

## Pre-existing user changes — preserve these

These were already present before the audit and are not audit edits:

- `app-misc/caelestia-cli/caelestia-cli-1.1.1.ebuild`
- `app-misc/caelestia-cli/files/caelestia-cli-non-arch-version.patch`
- `gui-apps/caelestia-shell/caelestia-shell-2.1.0_p20260706-r3.ebuild`
- `gui-apps/quickshell/quickshell-0.3.0.ebuild`

The Caelestia Shell and Quickshell `DISTRIBUTOR` values identify the package's
actual distribution/build channel, not the operating system or upstream
copyright holder. These overlay builds are distributed by `nekochigura`, not
the Gentoo repository, so preserve `DISTRIBUTOR="nekochigura"` when revising or
renaming either ebuild. In Caelestia Shell this value is only embedded in the
version-reporting helper; it does not alter licensing or runtime behavior.

`git diff --check` was clean at audit time.

## Work completed after the audit

### Repaired dependency submodule metadata

`nekochigura-dependencies` was recorded as a gitlink (`mode 160000`) but the
parent repository had no `.gitmodules`. A fresh checkout therefore created an
empty directory and `git submodule status` failed with:

```text
fatal: no submodule mapping found in .gitmodules for path 'nekochigura-dependencies'
```

With maintainer approval, `.gitmodules` was added with:

```ini
[submodule "nekochigura-dependencies"]
	path = nekochigura-dependencies
	url = https://github.com/melynx/nekochigura-dependencies.git
```

The submodule was initialized at the already-recorded parent gitlink commit:

```text
b54c421b429f7844ac7592442ebee9af653c936d
```

The restored archives were:

- `gui-apps/hyprdynamicmonitors/hyprdynamicmonitors-1.4.0-vendor.tar.xz`
- `gui-apps/hyprmon/hyprmon-0.0.12-vendor.tar.xz`
- `gui-apps/hyprmon/hyprmon-0.0.15-vendor.tar.xz`

`.gitmodules` is included with the parent SongRec fix so fresh clones can
initialize the dependency repository normally.

### Rust crate bundles removed and dependency history rewritten

The first SongRec implementation placed a 39,122,840-byte vendor archive in
`nekochigura-dependencies`; the initial Passless work added a second
26,399,076-byte crate archive. The maintainer subsequently chose individual
crates.io distfiles to minimize self-hosted content.

Both ebuilds now use locked `CRATES` lists and `${CARGO_CRATE_URIS}`:

- SongRec declares 345 crates.
- Passless declares 358 crates.
- Neither lockfile contains a Git dependency.
- Each Manifest records the upstream source archive and every individual
  crates.io distfile. Normal Portage fetch/mirror behavior supplies the crates;
  the overlay owner hosts no Rust dependency bundle.
- `cargo.eclass` deliberately emits its 300-or-more-crates QA notice for both
  packages. This known metadata/performance tradeoff is accepted in favor of
  not maintaining approximately 65.5 MB of derived archives.

The dependency repository's only remote ref, `master`, was force-rewritten
from `6c46defaa3c5185ec055840645397fe25fdf749c` to the last commit before either
Rust archive, `b54c421b429f7844ac7592442ebee9af653c936d`. Local reflogs were expired
and unreachable objects pruned. A fresh full mirror clone confirmed:

- only the three pre-existing Hyprland-related vendor archives remain;
- the removed SongRec commit `dc3c6ac5728ca85ac7d20d4b8cfe94eb433c6487`
  is unavailable;
- the removed Passless commit
  `6c46defaa3c5185ec055840645397fe25fdf749c` is unavailable; and
- no branch or tag retains either Rust archive.

The parent SongRec correction was committed and pushed as `ca04229`, updating
its ebuild and Manifest together with the dependency gitlink back to
`b54c421`.

### Claude Code stable and testing channel packaging

`dev-util/claude-code` now packages both Anthropic release channels: stable
2.1.204 is `KEYWORDS="amd64"`, while latest 2.1.211 is `KEYWORDS="~amd64"`.
This distinction is durable policy for this overlay: an upstream channel name
does not replace Gentoo keyword policy. When the pointers diverge, retain the
upstream stable version for stable Gentoo users and package the upstream latest
version for testing users instead of choosing only one channel.

- Replaced the old unbranded Google Cloud Storage base URL with Anthropic's
  documented `https://downloads.claude.ai/claude-code-releases` endpoint.
- Added the amd64 `cpu_flags_x86_avx` and `cpu_flags_x86_avx2` requirements
  used by the current native x64 binaries.
- Removed all twelve older ebuilds and their 48 Manifest entries. The Manifest
  now contains only the glibc and musl amd64 binaries for stable 2.1.204 and
  testing 2.1.211. Unkeyworded arm64 artifacts are not retained.
  `RESTRICT="bindist mirror strip"` remains in place, so none of Anthropic's
  proprietary binaries are mirrored or redistributed by the overlay.
- Removed the obsolete, unused `files/managed-settings.json`. The installed
  native managed settings retain `DISABLE_AUTOUPDATER=1`,
  `DISABLE_INSTALLATION_CHECKS=1`, and `installMethod=native`, keeping updates
  under Portage control and preventing a second home-directory installation.
- Downloaded Anthropic's release key, signed manifests, and detached signatures
  from the documented official endpoints. The key fingerprint matched
  `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`, the signature was good,
  and every retained binary matched its signed SHA-256 checksum.
- The 2.1.211 glibc and musl ELF files matched their declared x86-64
  architecture and libc interpreters. A clean staged amd64 glibc install
  passed; `claude --version` reported 2.1.211, command-line help ran, all shared
  libraries resolved, no RPATH or RUNPATH was present, and the installed tree
  contained no broken symlinks.

## Upstream updates found

### Accounts, administration, and crypto

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `app-admin/1password-bin` | stable 8.12.28; beta 8.12.30-19; CLI 2.35.0 | stable 8.12.28; beta 8.12.30-19; CLI 2.35.0 | Current after Issue 13. https://releases.1password.com/linux/stable/, https://releases.1password.com/linux/beta/, and https://releases.1password.com/developers/cli/ |
| `app-admin/azure-cli-bin` | 2.87.0-r1 | 2.87.0 | Current after Issue 23. https://github.com/Azure/azure-cli/releases/latest |
| `app-admin/talosctl-bin` | 1.13.6 | 1.13.6 | Current after Issue 26. https://github.com/siderolabs/talos/releases/tag/v1.13.6 |
| `app-crypt/passless` | 0.13.0 | 0.13.0 | Current after Issue 3. https://github.com/pando85/passless/releases/tag/v0.13.0 |
| `app-admin/ec-su_axb35` | snapshot 20260522 / `b8cab5a` | same HEAD found | Current. https://github.com/cmetz/ec-su_axb35-linux |
| `app-admin/ryzen_smu` | snapshot 20260425 / `0bb95d9` | `1be4fb1`, 2026-06-25 | Optional snapshot update; only test formatting and HX 370 verification documentation changed. https://github.com/amkillam/ryzen_smu/compare/0bb95d961664c7a0ac180f849fa16fe7da71922d...main |
| `app-crypt/picoforge` | 0.5.0 | 0.5.0 stable | Current. `v0.5.0+1` is a prerelease. https://github.com/librekeys/picoforge/releases/latest |

The `acct-*` packages are local account/group objects with no independent
upstream version stream.

### `app-misc`

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `google-cloud-cli` | 576.0.0 | 576.0.0 | Current after Issue 27. https://docs.cloud.google.com/sdk/docs/release-notes |
| `illogical-impulse-dotfiles` | snapshot 20260716 / `446504a` | same HEAD at resolution | Current after Issue 16. https://github.com/end-4/dots-hyprland/commit/446504ad427297dcbe5ee4a3d5bda1c458207cd9 |
| `moomoo-bin` | 16.24.16908 | 16.24.16908 | Current after Issue 28. https://www.moomoo.com/download/linux |
| `songrec` | 0.7.4 | 0.7.4 | Current after Issue 1. https://github.com/marin-m/SongRec/releases/tag/0.7.4 |
| `brightnessctl` | 0.5.1 | 0.5.1 | Current. https://github.com/Hummer12007/brightnessctl/releases |
| `caelestia-cli` | 1.1.1-r1 | 1.1.1 | Current after Issue 14. https://github.com/caelestia-dots/cli/releases/tag/v1.1.1 |
| `caelestia` | 2.1.0-r2 synthetic meta | Shell 2.1.0 / CLI 1.1.1 | Current as a local meta. |
| `cliphist` | 0.7.0 | 0.7.0 | Current. https://github.com/sentriz/cliphist/releases/tag/v0.7.0 |

The other `illogical-impulse-*` split packages are overlay-local dependency
groupings and have no independent upstream release streams. The obsolete
Bibata wrapper was removed in Issue 24 in favor of a generic all-variants
package vendored from GURU.

### Development and desktop

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `dev-python/curl-cffi` | 0.15.0 | 0.15.0 | Current after Issue 17. https://pypi.org/project/curl-cffi/0.15.0/ |
| `dev-util/claude-code` | stable 2.1.204; testing 2.1.211 | stable 2.1.204; latest 2.1.211 | Both verified channels packaged using Gentoo stable/testing keywords. https://downloads.claude.ai/claude-code-releases/stable |
| `dev-util/coder-bin` | 2.32.5 | 2.34.6 | Update. https://github.com/coder/coder/releases/tag/v2.34.6 |
| `dev-util/ghidra-bin` | 12.1 | 12.1.2 | Update. https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.2_build |
| `dev-util/opencode-bin` | 1.18.2 | 1.18.2 at resolution | Current after Issue 8. https://github.com/anomalyco/opencode/releases/tag/v1.18.2 |
| `gui-apps/caelestia-shell` | snapshot 20260716 / `dbb6d6c` | same HEAD at resolution | Current after Issue 14. https://github.com/caelestia-dots/shell/commit/dbb6d6c029021145422255dee6cd7ba607be3a20 |
| `gui-apps/hyprmon` | 0.0.15 | 0.0.17 | Update. https://github.com/erans/hyprmon/releases/tag/v0.0.17 |
| `gui-apps/hyprsunset` | 0.3.3 | 0.4.0 | Update. https://github.com/hyprwm/hyprsunset/releases/tag/v0.4.0 |
| `kde-plasma/breeze-plus` | 6.26.0 | 6.28.0 | Update. https://github.com/mjkim0727/breeze-plus/releases/tag/6.28.0 |

Current at audit time:

- `dev-embedded/rkdeveloptool` snapshot `304f073`
- `dev-lang/bun-bin` 1.3.14
- `dev-python/materialyoucolor` 3.0.3 plus live 9999
- `dev-tex/microtex` 1.0-r2 pinned to `0e3707f`, fixed in Issue 2
- `gui-apps/fuzzel` 1.14.1
- `gui-apps/hyprdynamicmonitors` 1.4.0
- `gui-apps/nwg-displays` 0.4.3
- `gui-apps/quickshell` 0.3.0 plus pinned snapshot 0.3.0_p20260710
- `gui-apps/wlogout` 1.2.2-r1
- `gui-apps/wtype` 0.4
- `gui-libs/xdg-desktop-portal-hyprland` 1.3.12

### Media, networking, science, system, and X11

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `material-symbols-variable` | snapshot 20260529 / `fef175fe` | `819d786`, 2026-07-10 | Update. https://github.com/google/material-design-icons/commit/819d78680a849ceef4c78f863d8753e3160b7c89 |
| `twemoji` | 17.0.2 | 17.0.3 | Update. https://github.com/jdecked/twemoji/releases/tag/v17.0.3 |
| `ipu6-camera-hal` | `20250923_ov02e` | `20260629_1` track available | Update/revalidate hardware track. https://github.com/intel/ipu6-camera-hal/tags |
| `gst-plugins-icamerasrc` | `20260629_1` | `20260629_1` | Current after Issue 6. https://github.com/intel/icamerasrc/tags |
| `ipu6-drivers` | 20260327 | `20260629_1` | Update. https://github.com/intel/ipu6-drivers/tags |
| `gpu-screen-recorder` | 5.13.6 plus live 9999 | 5.15.0 | Update versioned ebuild. https://git.dec05eba.com/gpu-screen-recorder/refs/ |
| `makemkv` | 1.18.4 | 1.18.4 | Current after Issue 7. https://www.makemkv.com/download/ |
| `video-compare` | 20260502 | 20260708 | Update. https://github.com/pixop/video-compare/tags |
| `wechat-bin` | 4.1.1.8 | 4.1.1.8 at resolution | Current with immutable artifact after Issue 4. https://linux.weixin.qq.com/ |
| `clash-party-bin` | 1.9.5 | 2.0.0 | Update. https://github.com/mihomo-party-org/clash-party/releases/tag/v2.0.0 |
| `hipsparselt` | 7.2.0 | ROCm 7.2.4 | Update. https://github.com/ROCm/rocm-libraries/releases/tag/rocm-7.2.4 |
| `sci-ml/ollama` | 0.23.2 | 0.32.0 | Update. https://github.com/ollama/ollama/releases/tag/v0.32.0 |
| `sci-ml/ollama-bin` | 0.30.0 | 0.32.0 | Update. Same source. |
| `x11-themes/darkly` | 0.5.37 | 0.5.38 | Update. https://github.com/Bali10050/Darkly/releases/tag/v0.5.38 |

Current at audit time:

- Nerd Fonts 3.4.0
- Rubik pinned current commit `e337a5f`
- Space Grotesk 2.0.0
- Alass 2.0.0
- libcava 0.10.7
- v4l2-relayd 0.2.0
- DisplayLink driver 6.3
- EVDI 1.15.0
- RyzenAdj 0.19.0
- libxcb 1.17.0
- Bibata 2.0.7, with the all-variants ebuild vendored from GURU
- Matugen 4.1.0
- adw-gtk3 6.5
- Catppuccin Neovim 2.0.0
- qtengine 0.2.1
- Readex Pro upstream HEAD, but its ebuild is mutable and mislabeled
- OneUI4 Icons upstream HEAD, but its ebuild is mutable
- Howdy pinned current HEAD `d3ab993`
- Sweet cursor snapshot is one commit behind repository HEAD, but the packaged
  `kde/cursors` content did not change in the comparison
- IPU6 camera bins has divergent hardware release tracks; no unambiguous direct
  successor to local `20250923_ov02e` was selected

## Issue backlog — handle sequentially

### Issue 1 — SongRec build is network-dependent and incomplete

Status: fixed, verified, and published.

Affected: every ebuild in `app-misc/songrec`; newest example
`songrec-0.7.3.ebuild:18-39`.

Findings:

- Every retained version calls `cargo fetch --locked` from `src_prepare`.
- `RESTRICT="network-sandbox"` is not a valid Gentoo package restriction, so
  normal Portage networking remains blocked and the build fails.
- Dependencies are not immutable/mirrorable and can disappear upstream.
- 0.7.3 lacks required system dependencies used by 0.7.4/default features:
  libsoup3, gettext, PipeWire, clang/libclang, and ffmpeg.
- Old 0.4.3 and 0.5.0 have empty `DEPEND`/`RDEPEND` despite installing and
  building a GTK application.
- Desktop/AppStream installation in old versions does not use appropriate
  helpers/eclasses.
- All versions unnecessarily restrict stripping.
- Package lacks `metadata.xml` with upstream remote ID.
- Seven old ebuilds are fully shadowed.

Implemented with maintainer approval:

- Added `songrec-0.7.4.ebuild`, using `cargo.eclass`, a locked 345-entry
  `CRATES` list, and standard crates.io distfiles for a network-free build
  after Portage's fetch phase.
- Added complete GTK4/libadwaita, ALSA, PipeWire, optional PulseAudio,
  libsoup3, FFmpeg, DBus, Clang, gettext, Blueprint, and pkg-config
  dependencies. OpenSSL was removed because it is absent from the 0.7.4 lock
  graph.
- Declared Rust 1.88 as upstream's MSRV and retained `~amd64 ~arm64`; `x86` is
  excluded because that Rust version is not solvable on Gentoo x86 profiles.
- Added `metadata.xml` and installed the binary, desktop entry, AppStream
  metadata, complete hicolor icon tree, translations, compressed man page, and
  README.
- Removed the seven fully shadowed ebuilds from 0.4.3-r1 through 0.7.3 and
  regenerated the Manifest.
- `pkgcheck` reported no findings for the new ebuild before pruning or for the
  final package after pruning. `metadata.xml` validation and `git diff --check`
  also passed.
- A clean Portage run verified and unpacked all 345 individual crate distfiles
  without build-time networking, then completed the optimized build and staged
  install with an unprivileged image owner. The 15.8 MiB installed tree
  contained the expected binary and desktop assets; the stripped PIE reported
  version 0.7.4 and had no RPATH/RUNPATH.
- Added the dependent crate license set and regenerated the Manifest to 346
  distfiles: the upstream source plus 345 crates.

### Issue 2 — MicroTeX ebuild is effectively broken

Affected: `dev-tex/microtex/microtex-1.0-r1.ebuild`.

Status: fixed and verified as `microtex-1.0-r2`; the broken revision was
removed.

- `DEPEND` was empty and `RDEPEND` was incomplete despite compiling/linking
  tinyxml2, gtkmm, gtksourceviewmm, cairomm, and Fontconfig.
- CMake and pkg-config build dependencies are undeclared.
- Build commands at lines 39-43 do not consistently use Gentoo helpers or
  `|| die`.
- `build/LaTeX` is installed using `doins` at lines 48-49, producing a
  non-executable file.
- The `tinyxml2.so.10` sed is a no-op against pinned upstream CMake, which links
  `tinyxml2` rather than embedding that SONAME.
- arm64 dependencies are unsatisfiable in tested Gentoo profiles.
- Missing `metadata.xml` remote ID and standard metadata.

Implemented with maintainer approval:

- Added `microtex-1.0-r2` using `cmake.eclass`, the full pinned upstream commit
  hash, standard unpack/configure/compile phases, and a revision-independent
  distfile name.
- Declared the actual cairomm:0, gtkmm:3.0, gtksourceviewmm:3.0, tinyxml2,
  Fontconfig, and pkg-config dependencies. Keywords are now `~amd64 ~x86`;
  `arm64` was removed because Gentoo has no matching gtksourceviewmm:3.0.
- Added a minimal upstream-source patch to include
  `fontconfig/fcfreetype.h`, which current Fontconfig requires for
  `FcFreeTypeQuery`.
- Installed the executable with executable permissions, installed its required
  `libLaTeX.so` into the normal library directory, and placed resources under
  `/usr/share/clatexmath`, one of the paths used by `LaTeX::init()`.
- Disabled the upstream production log/debug macros and build-tree RUNPATH.
- Added `metadata.xml`, removed the ineffective tinyxml2 SONAME sed and strip
  restriction, pruned `-r1`, and regenerated the Manifest.
- A clean CMake/Ninja build and staged install passed. The staged executable had
  no RUNPATH, resolved the staged `libLaTeX.so`, found the XDG resource tree,
  and rendered `\\sqrt{x^2+y^2}` headlessly to a valid 10,022-byte SVG.
- Final `pkgcheck`, XML validation, and `git diff --check` passed.
- For verification, Portage installed `dev-libs/tinyxml2-11.0.0`,
  `x11-libs/gtksourceview-3.24.11-r4`, and
  `dev-cpp/gtksourceviewmm-3.18.0-r2` from binary packages on the test host.

### Issue 3 — Passless USE/features and dependency wiring

Status: fixed and verified as 0.13.0; all superseded versions were removed.

Affected: all `app-crypt/passless` ebuilds; newest lines cited below.

- `tpm` is declared at line 382 and adds `tpm2-tss` at line 387, but build lines
  411-417 never pass Cargo feature `tpm`; USE=tpm produces a binary without the
  TPM backend.
- Default usage expects the `pass` password store, but no runtime dependency on
  `app-admin/pass` is declared.
- `RUST_MIN_VER` is assigned after `inherit cargo`; cargo.eclass reads it at
  inherit time, so the assignment is ignored. The stated 1.70 is below the
  current eclass floor and should be replaced with the actual upstream MSRV.
- `tpm` lacks a metadata USE description.
- Package needs update from 0.11.2 to 0.13.0.

Implemented with maintainer approval:

- Added `passless-0.13.0.ebuild` using `cargo.eclass`, a locked 358-entry
  `CRATES` list, and `${CARGO_CRATE_URIS}`. The lockfile contains no Git
  dependencies, and no Passless dependency archive is self-hosted.
- Set `RUST_MIN_VER=1.91.0` before inheriting `cargo.eclass`. This is the
  highest declared MSRV in the locked graph, required by the Soft FIDO2 0.13.1
  crates.
- Wired USE=`tpm` to Cargo feature `tpm` and the `app-crypt/tpm2-tss`
  dependency. Added the missing default-backend runtime dependency on
  `app-admin/pass`, retained the UHID/libusb/DBus requirements, and made the
  user systemd unit conditional on USE=`systemd`.
- Added `metadata.xml` with the TPM USE description and upstream links. The
  installed payload includes the binary, user service, udev rule, sysusers
  configuration, modules-load configuration, and upstream documentation.
- Removed versions 0.7.0, 0.7.1, 0.7.6, 0.9.3, 0.10.1, and 0.11.2, then
  regenerated the Manifest to 359 distfiles: the 0.13.0 source plus 358
  individual crates.
- A clean offline build and staged install passed without TPM. A second clean
  offline build and staged install passed with USE=`tpm`; both Cargo build and
  install commands received `--features tpm`, and the resulting PIE executable
  linked the TPM2 ESAPI, TCTI loader, and MU libraries. Both binaries reported
  version 0.13.0, had no RPATH/RUNPATH, and Portage stripped them successfully.
- Final `pkgcheck`, XML validation, Manifest validation, and
  `git diff --check` passed. The expected 300-or-more-crates eclass QA notice
  is accepted to avoid hosting a derived archive.

### Issue 4 — WeChat source artifact is mutable and currently mismatched

Status: fixed by `net-im/wechat-bin/wechat-bin-4.1.1.8.ebuild`.

- Replaced the mutable, mismatched 4.1.1 download with DebianCN's versioned
  `wechat_4.1.1.8_amd64.deb` URL. The mirrored file and Tencent's current
  official download were byte-identical: 212,419,528 bytes, SHA-256
  `c9765e87ee5133bf4bb50d585c1814fafd995e3fb0da62c5ed07259b43dada7b`,
  and SHA-512
  `949a43c79abdc672f52588a07c2345ed5499ea269c88e6f82b4b3aaefb78d1ebb35d6200bbd6b6d47f7196870ad058d2cd4dc46d29da538b9221f4755ec365df`.
  Its Debian metadata identifies version 4.1.1.8 and amd64 architecture.
- Retained `RESTRICT="bindist mirror strip"`, so the overlay does not host or
  redistribute the proprietary package. The versioned upstream mirror is the
  sole distfile source.
- Completed the binary runtime dependency closure found from the staged ELF
  tree, including NSS/NSPR, fontconfig, PulseAudio, D-Bus, zlib, and the xcb
  utility libraries.
- Normalized eight vendor RUNPATHs to `${ORIGIN}` with `patchelf`; this removes
  relative, empty, and vendor build-host paths. The compressed vendor changelog
  is unpacked before `dodoc` so Portage installs it normally.
- A clean staged install passed without QA or security notices. It installed
  135 application files (718.3 MiB); the main PIE executable, wrapper, desktop
  entry, icons, helper executables, and shared libraries were present and all
  runtime libraries resolved on the test host.
- Removed 4.1.0.13, 4.1.0.16, and 4.1.1, then regenerated the Manifest with
  only the immutable 4.1.1.8 distfile. Final `pkgcheck`, XML validation,
  Manifest validation, and `git diff --check` passed.

### Issue 5 — Mutable branch archives and Readex metadata/license

Status: fixed by `media-fonts/readex-pro/readex-pro-1.2_p20250213.ebuild`
and `x11-themes/oneui4-icons/oneui4-icons-1.0_p20250425.ebuild`.

- Neither upstream publishes tags or releases. Replaced the mutable branch
  archives with date-stamped snapshots pinned to full commits: Readex Pro
  `563dfbb36ae45e52ec50829b016ce724ac2fca70` from 2025-02-13 and OneUI4
  Icons `693095d45c67e6b48a9873e36af6283f05080e66` from 2025-04-25.
- Corrected Readex's license from GPL-2 to the upstream `OFL.txt` declaration,
  `OFL-1.1`, and replaced the unrelated description. Both packages now have
  upstream homepages and `metadata.xml` files with maintainer, description,
  issue tracker, and repository information.
- Readex now uses `font.eclass` for installation. Its staged image contains all
  six Readex Pro TTF styles, generated X font indexes, and upstream authors,
  contributors, and README documentation.
- OneUI4 now inherits `xdg`, depends on its declared hicolor parent theme, and
  removes empty dependency assignments and unsafe/unnecessary path handling.
  Staged installation contains the OneUI, OneUI-dark, and OneUI-light themes
  with 10,628 regular files.
- Found eight broken scalable MIME aliases in the upstream OneUI snapshot.
  Five now target equivalent fixed-resolution icons shipped by the theme; the
  three aliases with no available target are removed so lookup can fall back to
  hicolor. The final installed tree has no broken symlinks.
- Removed the mutable 1.0-r1 ebuilds and regenerated both Manifests with only
  their commit-pinned distfiles. Clean staged installs completed without QA
  notices; final `pkgcheck`, XML validation, Manifest validation, and
  `git diff --check` passed.

### Issue 6 — icamerasrc has nonexistent/exact dependency atoms

Status: fixed by
`media-plugins/gst-plugins-icamerasrc/gst-plugins-icamerasrc-0.0.0_p20260629.ebuild`.

- Updated to upstream tag `20260629_1`, commit
  `fe01f98a09b7b864c36ef60a146cdc4e1bf125a6`, and removed the 20251104 and
  20251226 snapshots.
- Revalidated upstream's DRM-format checks. The current code first accepts
  GStreamer 1.23 or newer and only retains exact 1.22.6 as a legacy fallback.
  Replaced the nonexistent exact atom with a conditional
  `>=media-libs/gstreamer-1.23:1.0` dependency.
- Completed the DRM dependency closure with
  `media-libs/gst-plugins-bad:1.0[vaapi]` for `gstreamer-va-1.0` and
  `media-libs/libva:=` for `libva` and `libva-drm`. The base build continues
  to require libdrm because upstream checks and links it unconditionally.
- Corrected the license to `LGPL-2.1+` from upstream's LGPL 2.1-or-later
  notices. Added `metadata.xml` with maintainer and upstream information and a
  description of the `drm` USE flag.
- Clean staged builds and installs passed with both USE=`-drm` and USE=`drm`
  on GCC 16. The generated configurations respectively omitted and defined
  `GST_DRM_FORMAT`; the DRM binary linked GStreamer VA, libva, and libva-drm.
  Both installed plugins had no RPATH/RUNPATH, resolved their complete shared
  library sets against staged IPU6 dependencies, and registered successfully
  as `icamerasrc` with `gst-inspect-1.0` (without camera hardware available).

### Issue 7 — MakeMKV dependency set is obsolete

Status: fixed by `media-video/makemkv/makemkv-1.18.4.ebuild`.

- Updated to MakeMKV 1.18.4, released 2026-06-15. The proprietary archive
  continues to provide amd64, arm64, armhf, and i386 executables; upstream's
  1.18.4 release specifically fixes an armhf crash.
- Upstream 1.18.4 still supports only Qt 5. Activated the existing local Qt 6
  port, which converts the generated configure checks and MOC discovery to
  Qt 6, selects C++17, and adjusts the four GUI source incompatibilities.
- Replaced the removed split Qt 5 atoms with
  `dev-qt/qtbase:6[dbus,gui,widgets]` and the host-side Qt base build tool.
  Replaced deprecated `sys-libs/zlib` with `virtual/zlib:=`, and switched the
  homepage and distfile URLs to HTTPS.
- Retained `RESTRICT="bindist mirror"` and the existing EULA/license set, so
  the proprietary upstream archive is neither mirrored nor redistributed.
  Added package metadata with maintainer, forum, and release-history links.
- A clean USE=`-gui -java` build and staged install passed on GCC 16 and FFmpeg
  8. A second clean USE=`gui java` build and staged install passed against Qt
  6.11.1; configure found Qt6 Core, Gui, Widgets, and DBus and used Qt 6's MOC.
- The CLI reported MakeMKV 1.18.4 and handled a robot-mode information query.
  The Java archive and policy were absent with USE=`-java` and present with
  USE=`java`. The Qt 6 GUI started successfully with the offscreen backend and
  stayed running until the test timeout.
- All staged ELF dependencies resolved, including the Qt 6 GUI libraries, and
  no installed ELF contained RPATH/RUNPATH. The desktop entry was valid, the
  installed tree had no broken symlinks, and Portage emitted no QA or security
  notices. Removed versions 1.17.7 and 1.18.3 plus the obsolete 1.17.7-only
  FFmpeg patches; the Manifest now contains only the two 1.18.4 archives.

### Issue 8 — CPU-dependent binary selection in OpenCode and Bun

Status: fixed by `dev-util/opencode-bin/opencode-bin-1.18.2.ebuild` and
`dev-lang/bun-bin/bun-bin-1.3.14-r1.ebuild`.

- Updated OpenCode from 1.17.3 to upstream 1.18.2 and removed all older
  versions. The amd64 ebuild now fetches only upstream's x64 baseline archive;
  it no longer downloads the optimized archive or reads `/proc/cpuinfo` during
  `src_unpack`. Binpkgs are therefore deterministic and portable across the
  Gentoo amd64 baseline. The arm64 archive remains unchanged.
- Corrected OpenCode's package license from Apache-2.0 to MIT to match the
  current upstream license.
- Bun 1.3.14 remains the latest upstream release, so replaced it with revision
  1.3.14-r1 and removed all older versions. The amd64 glibc and musl branches
  now respectively use upstream's `x64-baseline` and `x64-musl-baseline`
  archives. The regular aarch64 glibc and musl artifacts remain in use because
  upstream's baseline distinction is x86-specific.
- Added the standard Gentoo Authors/GPL-2 ebuild header that all previous Bun
  ebuilds lacked. This header covers the packaging code; Bun itself remains
  declared under its upstream MIT license. Replaced manual completion-path
  installation with the `shell-completion` eclass helpers.
- Clean staged amd64 installs passed for OpenCode and for Bun with completions
  both disabled and enabled. OpenCode reported 1.18.2; Bun reported 1.3.14 and
  executed a JavaScript smoke test. The disabled build contained no completion
  files, while the enabled build installed both zsh and fish completions.
- Revalidated all six release archives. The amd64 baseline glibc binaries use
  the x86-64 glibc interpreter, Bun's amd64 musl baseline uses the x86-64 musl
  interpreter, and the arm64 glibc/musl binaries use their corresponding
  aarch64 interpreters. All archive layouts match the ebuild conditionals.
  Staged amd64 ELF dependencies resolve, neither binary has RPATH/RUNPATH, and
  the installed trees contain no broken symlinks. Final `pkgcheck`, Manifest,
  XML, and whitespace validation passed.

### Issue 9 — Quickshell hardcodes lib64 and lacks metadata

Affected: `gui-apps/quickshell/quickshell-0.3.0.ebuild`.

Status: fixed in `gui-apps/quickshell/quickshell-0.3.0-r1.ebuild`.

- Replaced the hardcoded `lib64/qt6/qml` CMake argument with
  `$(get_libdir)/qt6/qml`. The active profile maps amd64 to `lib64` and x86 to
  `lib`, so the existing x86 keyword no longer installs QML metadata into the
  wrong ABI directory.
- Preserved the maintainer's `DISTRIBUTOR="nekochigura"` branding in the new
  revision. The staged executable reports that distributor in `--version`.
- Added `metadata.xml` with the upstream GitHub, documentation, and bug-tracker
  links and descriptions for every package-local USE flag.
- Added GURU's stable-version strict-aliasing fix for `ObjectModel::values()`.
  It replaces an undefined type-punned `QList` access with an element-wise
  conversion. Added a second focused patch for GCC 16 findings: unknown
  NetworkManager states and Wi-Fi modes now return their `Unknown` values, an
  intentional LEAP-to-WEP validation fallthrough is annotated, and the fatal
  invalid-UPower-profile path is marked unreachable.
- Clean source preparation applied both patches. Clean minimal-feature and
  full default-feature amd64 builds and staged installs passed; an incremental
  full rebuild after the GCC 16 patch produced no severe Portage QA notice.
  The minimal and full images installed their QML metadata under
  `/usr/lib64/qt6/qml`, and the full image contained the expected Networking,
  UPower, Wayland, X11, I3, Hyprland, Bluetooth, and service modules.
- The staged binary reported Quickshell 0.3.0 with `nekochigura` branding, all
  ELF dependencies resolved, the image had no broken symlinks, and desktop-file
  validation passed. Final Manifest, XML, `pkgcheck`, and whitespace validation
  passed. Upstream's latest release remains v0.3.0.

### Issue 10 — Missing custom Intel camera-bins license

Affected: `media-libs/ipu6-camera-bins-1.0.1_p20250923.ebuild`.

Status: fixed in `media-libs/ipu6-camera-bins-1.0.1_p20250923.ebuild`.

- Added `licenses/intel-ipu6-camera-bins`, byte-for-byte identical to the
  license in Intel's `20250923_ov02e` tag. It permits redistribution only in
  unmodified binary form, prohibits reverse engineering, and includes a
  limited patent grant; the package therefore retains `RESTRICT="strip mirror
  bindist"` because removing unsafe vendor RUNPATH entries modifies the blobs.
- Retained the existing `chrpath` cleanup. The tagged archive contains 12
  libraries with `/p/ipu/external/intel/gcc-9.2.0/lib:` (including a dangerous
  empty path element) and three with `/usr/lib`; the prepared and staged trees
  contain no RPATH or RUNPATH entries after cleanup.
- Added `metadata.xml` with the Intel GitHub remote. Added the standard Gentoo
  Authors/GPL-2 ebuild header and corrected variable order and indentation.
- A clean staged amd64 install passed. It contains all 57 source shared
  libraries and 57 valid unversioned linker symlinks, has no broken symlinks or
  unresolved ELF dependencies, and the installed binaries and headers match
  the prepared source. Manifest, XML, `pkgcheck`, license checksum, and
  whitespace validation passed.
- No version bump is available: the later annotated tag `20260629_2` and the
  packaged `20250923_ov02e` tag both resolve to source commit
  `30e87664829782811a765b0ca9eea3a878a7ff29`.

### Issue 11 — Illogical Impulse keywords and wrong jq dependency

Affected: multiple `app-misc/illogical-impulse-*` metapackages.

Status: fixed across the Illogical Impulse metapackages, with the functional
dependency change in `illogical-impulse-basic-1.0-r3.ebuild`.

- Replaced `dev-python/jq` with `app-misc/jq`. Current upstream describes `jq`
  as a widely used command and its shell scripts invoke that executable;
  `dev-python/jq` is a Python binding that only happened to pull in the CLI
  transitively. Revision 1.0-r2 was removed so installed systems upgrade to the
  corrected dependency.
- Restricted the master, basic, fonts/themes, Hyprland, portal, screencapture,
  toolkit, and widgets metapackages to `~amd64`, matching dependencies such as
  current Hyprland, xdg-desktop-portal-hyprland, hyprshot, wtype, and fuzzel.
  Preserved supported component arches instead of dropping them globally:
  audio, backlight, and Python retain `~arm64`; MicroTeX retains `~x86`; and
  Bibata, KDE, OneUI, and Quickshell retain `~x86`; KDE, OneUI, and Quickshell
  also retain `~arm64`. Python's
  x86 keyword was removed because `dev-python/uv` is profile-unsolvable there.
- Corrected the Hyprland and KDE packages from `GPL-2` to `metapackage` because
  they install no payload. Added the real dots-hyprland homepage and upstream
  metadata throughout, and removed empty `DEPEND` assignments and ineffective
  `RESTRICT="strip"`.
- All 16 affected ebuilds parsed and completed clean staged installs with the
  expected empty images. The complete amd64 master dependency graph resolved
  against this checkout with zero backtracking and selected basic 1.0-r3;
  `dev-python/jq` was absent. Final all-profile `pkgcheck`, Manifest, and
  whitespace validation passed.

### Issue 12 — Invalid category-root app-misc files

Status: fixed by removing `app-misc/Manifest` and `app-misc/metadata.xml`.

- The category-root Manifest was the exact same Git blob as
  `app-misc/cliphist/Manifest`; Manifests belong in package directories.
- The category-root metadata was likewise the exact same Git blob as
  `app-misc/cliphist/metadata.xml`, containing cliphist `pkgmetadata` rather
  than category `catmetadata`.
- No replacement category file is needed because the master Gentoo repository
  supplies valid `app-misc` category metadata. The legitimate cliphist
  Manifest and metadata remain unchanged and pass Manifest, XML, all-profile
  `pkgcheck`, and whitespace validation.

### Issue 13 — 1Password channel/version/install design

Affected: all `app-admin/1password-bin` ebuilds.

Status: fixed by splitting the release channels, updating all artifacts, and
matching the current upstream helper-security model.

- Stable and beta releases share the same package and SLOT, so users cannot
  select a persistent release channel.
- Upstream beta build numbers are encoded using Gentoo `-rN`, conflating vendor
  build identity with Gentoo package revision semantics.
- `pkg_postinst` performs live-root `chmod`/`chgrp` for the setuid sandbox and
  BrowserSupport instead of recording ownership/modes in the image using
  `fowners`/`fperms`.
- This complicates ROOT/binpkg behavior and package ownership tracking.
- `QA_EXECSTACK` suppresses an executable-stack warning for the setuid sandbox;
  verify the vendor binary truly needs the exception.
- `cli` USE is undocumented.
- Update stable desktop and CLI versions after channel policy is chosen.

Related account issue:

- `acct-group/onepassword-cli` hardcodes GID 1560. 1Password integration needs
  a group ID >=1000, so a normal dynamic system GID is unsuitable, but the
  fixed user-range allocation must be documented/reserved and collision-safe.

Resolution and verification:

- Stable remains `app-admin/1password-bin`, now at 8.12.28. Beta is the new
  persistent atom `app-admin/1password-beta-bin`, with vendor build
  `8.12.30-19.BETA` represented as Gentoo version `8.12.30_beta19`. Reciprocal
  strong blockers prevent file collisions between the two channels. The two
  beta builds formerly encoded as Gentoo `-rN` revisions and all other obsolete
  versions were removed.
- Both packages bundle the current stable CLI 2.35.0 behind the documented
  `cli` USE flag. The `policykit` flag is documented as well.
- All stable, beta, and CLI artifacts for both architectures were verified
  against 1Password's published signing key, fingerprint
  `3FEF9748469ADBE15DA7CA80AC2D62742012EA22`; all six detached signatures were
  good before the Manifest hashes were accepted.
- Upstream's installer scripts create three distinct regular-range groups for
  peer authentication. The overlay therefore reserves GIDs 1559, 1560, and
  1562 for `onepassword`, `onepassword-cli`, and `onepassword-mcp`
  respectively. The CLI keeps its existing 1560 allocation to avoid a local
  migration; 1561 was skipped because it is already assigned to `i2c` on the
  maintainer's system. All three packages enforce their selected ID, reject
  IDs below 1000, fail closed on collisions, and document the corresponding
  `ACCT_GROUP_*_ID` override for sites that need another unused high GID.
- Setuid/setgid ownership is now recorded in the image: `chrome-sandbox` is
  root:root 4755, `1Password-BrowserSupport` is root:onepassword 2755,
  `1password-mcp` is root:onepassword-mcp 2755, and optional `op` is
  root:onepassword-cli 2755. No live-root permission changes remain in
  `pkg_postinst`.
- Current stable and beta amd64 artifacts report a non-executable GNU stack
  (`RW-`) for the sandbox and primary helper binaries, so the obsolete
  `QA_EXECSTACK` suppression was removed.
- Installation now preserves upstream executable modes, omits upstream package
  manager scripts, provides the current MCP aliases, installs the upstream
  desktop/icons/PolicyKit/custom-browser files, and avoids duplicating the
  complete Electron resources directory under documentation.
- Clean staged amd64 installs passed for stable with `cli policykit` and beta
  with both flags disabled. Image inspection confirmed the declared ownership
  and modes, PolicyKit generation, custom-browser configuration, MCP aliases,
  absence of removed installer scripts, resolved shared libraries, and no
  broken symlinks. The CLI reported version 2.35.0.

### Issue 14 — Caelestia snapshot and runtime dependencies

Affected user-modified files; preserve local branding/patch changes.

Status: fixed with reproducible matching snapshots, complete direct runtime
dependencies, and the missing CLI completion.

`gui-apps/caelestia-shell`:

- PV says snapshot 20260706, but pinned commit was made 2026-06-30.
- Current main at resolution time is 2026-07-16.
- Pinned upstream README says Quickshell must be the Git version, while the
  ebuild accepts tagged `>=0.3.0`.
- QML invokes `hyprctl` and `xmllint`, but dependencies on Hyprland and
  libxml2 are absent.

`app-misc/caelestia-cli`:

- `caelestia install/update` executes Git operations, but unconditional
  `dev-vcs/git` runtime dependency is absent.
- Upstream ships a fish completion that is not installed.
- Preserve the existing non-Arch version patch.

Resolution and verification:

- Replaced the inaccurately dated shell package with
  `caelestia-shell-2.1.0_p20260716`, pinned to upstream commit
  `dbb6d6c029021145422255dee6cd7ba607be3a20` from 2026-07-16. All three
  existing local patches remain necessary and apply cleanly. The local
  distributor value is preserved as `nekochigura`.
- Added reproducible `quickshell-0.3.0_p20260710`, pinned to the exact
  Quickshell revision in the shell's `flake.lock`,
  `4df562dfb2475a9057f0f33a8db75808efad8670`. The shell now requires
  `>=gui-apps/quickshell-0.3.0_p20260710`, excluding the incompatible tagged
  release without introducing a moving live-ebuild dependency. The existing
  stable Quickshell ebuild remains available.
- Both existing Quickshell GCC 16/strict-aliasing patches apply to the pinned
  snapshot. Because a commit archive has no Git metadata, the ebuild passes
  `GIT_REVISION` explicitly; the staged executable reports the exact pin and
  `nekochigura` distributor instead of an empty revision.
- Added direct shell runtime dependencies for `hyprctl`, `xmllint`, `pidof`,
  `notify-send`, and the directly read XKB rules data: `gui-wm/hyprland`,
  `dev-libs/libxml2`, `sys-process/procps`, `x11-libs/libnotify`, and
  `x11-misc/xkeyboard-config`.
- Revised the still-current CLI release to `caelestia-cli-1.1.1-r1`, preserving
  both the dots-only and non-Arch Portage-version patches. `dev-vcs/git` is now
  an unconditional runtime dependency because install, update, legacy
  detection, and diagnostics execute Git. The upstream Fish completion is
  installed with the `shell-completion` eclass.
- Clean amd64 builds and staged installs passed for Quickshell, the shell, and
  CLI under both Python 3.13 and 3.14. Quickshell's full default feature set
  built with GCC 16 and Qt 6.11; its ELF has a non-executable stack, no text
  relocations, no unresolved symbols or libraries, and a valid `qs` symlink.
  The shell installed 19 resolved ELF files and its QML modules under the
  correct `lib64/qt6/qml` path with no broken symlinks. Its version helper
  reports version 2.1.0, the exact pinned revision, and distributor
  `nekochigura`.
- The staged CLI reports version 1.1.1 through the Portage-aware patch, exposes
  `install --no-packages`, and installs a byte-identical, syntax-valid Fish
  completion under `vendor_completions.d`. Regenerated Manifests, final
  `pkgcheck`, and whitespace validation passed.

### Issue 15 — cliphist uses an undocumented third-party vendored fork

Affected: `app-misc/cliphist/cliphist-0.7.0.ebuild:10`.

Status: fixed with the official upstream source, a reproducible minimal vendor
archive, and security/privacy backports.

- Homepage/metadata identify official `sentriz/cliphist`.
- Source archive comes from `henri-gasc/cliphist`.
- Comparison found the fork differs mainly by a checked-in `vendor/` tree,
  explaining the 13 MiB vs roughly 356 KiB source size.
- Document this provenance/trust exception or replace it with a dependency
  archive generated and hosted using this overlay's dependency-repository
  convention.

Resolution and verification:

- Replaced `cliphist-0.7.0` with `cliphist-0.7.0-r1`, sourced from the official
  `sentriz/cliphist` v0.7.0 tag. The release remains current.
- Removed the source dependency on the third-party fork. The separate
  dependency repository now contains only a deterministic `vendor/` archive,
  pinned by immutable dependency commit
  `43ec2e46b358b709ed53d4e07dc9870f7f02ca5e`. Its documented regeneration
  recipe produces the same 692,916-byte archive with SHA-256
  `045de9f3c291fb2bf190af9724cec8689310ac577f599d4890a2bc381cd214cf`.
- Updated the reachable TIFF decoder from `golang.org/x/image` 0.21.0 to
  0.44.0, resolving GO-2026-4815, and raised the build requirement to Go
  1.25.0 as required by that module version.
- Backported official upstream commit
  `25cc3e4affb6d24398cbcb2f42d8e8cf9cf62823`, so newly created clipboard
  databases use mode 0600 rather than 0644. `pkg_postinst` warns that existing
  databases retain their permissions and gives the administrator a corrective
  `chmod` command.
- Build and test phases force the vendored module graph with network module
  resolution disabled and use `-trimpath`. A clean Portage build passed the
  full upstream test suite, including TIFF preview and no-permission tests.
  The staged PIE has a non-executable stack, records `x/image v0.44.0` and
  `-trimpath`, and an isolated store operation created its database with mode
  0600. Regenerated Manifest, final `pkgcheck`, and whitespace validation
  passed.

### Issue 16 — keyworded git-r3 dotfile snapshots

Affected: all `app-misc/illogical-impulse-dotfiles` ebuilds.

Status: fixed with Manifested upstream archives and a current reproducible
snapshot.

- Pinned commits are reproducible, but the keyworded packages inherit
  `git-r3`, remain unmirrorable VCS packages, and trigger VisibleVcsPkg.
- Switch to pinned GitHub commit tarballs plus Manifested submodule/source
  archives, or clear KEYWORDS.
- FILESDIR contains multiple identical version-specific patch copies; use
  stable patch names where content is identical.
- Update snapshot to current main only after packaging method is fixed.

Resolution and verification:

- Replaced the three keyworded `git-r3` ebuilds with `-r1` revisions using
  immutable GitHub commit archives, and added current
  `illogical-impulse-dotfiles-0_p20260716` at upstream commit
  `446504ad427297dcbe5ee4a3d5bda1c458207cd9`. The retained snapshot dates now
  continue to match their pinned upstream commit dates.
- All four parent commits contain one identical gitlink at
  `dots/.config/quickshell/ii/modules/common/widgets/shapes`, pinned to
  `end-4/rounded-polygon-qmljs` commit
  `e31ec4cb4ebf6a46b267f5c42eabf6874916fa16`. Each ebuild assembles that one
  official submodule commit archive into the empty gitlink directory. No
  dependency-repository artifact or other self-hosting is used.
- Added a five-distfile Manifest covering the four parent snapshots and the
  one shared submodule archive. Independent downloads matched Portage's
  BLAKE2B/SHA512 values, archive roots, gitlink target, and assembled file
  layout.
- Corrected `LICENSE` from `GPL-3` to `GPL-3 Apache-2.0`; the installed parent
  is GPL-3 and the installed shapes submodule is Apache-2.0. Runtime
  `dev-vcs/git` remains necessary for the deployed update, merge, diagnostic,
  and installer helpers.
- Consolidated 16 version-specific patch files into seven stable shared
  patches plus the unique March OS-detection patch. The archive-only
  deployment keeps the submodule-update guard, and all declared patch sets
  apply cleanly to their snapshots, including the July update.
- Corrected executable-mode preservation: all installed shell scripts remain
  executable as before, while executable Python helpers and extensionless
  upstream entry points such as `diagnose` and `hypr_mon_guard` no longer lose
  their modes through `doins`.
- Two independent offline Portage installs of each of the four ebuilds passed.
  Their normalized path/type/mode/size/content manifests are identical. The
  images contain the submodule files and both licenses directly at the
  expected paths, contain no `.git` metadata, nested archive root, patch
  residue, or broken links, and pass the shell syntax sweep. The staged July
  setup help also runs successfully without network access.
- Package QA no longer reports `VisibleVcsPkg` or duplicate patch files. Its
  only package result is `RedundantVersion` for the three deliberately
  retained rollback snapshots; whitespace and ebuild syntax validation pass.

### Issue 17 — curl-cffi license and test dependencies

Affected: `dev-python/curl-cffi` 0.13.0 and 0.14.0.

Status: fixed with the stable 0.15.0 PyPI sdist and system
`curl-impersonate` linking.

- Removed 0.13.0 and 0.14.0, corrected `LICENSE` from BSD-2 to MIT, and added
  the new mandatory `rich` runtime dependency plus upstream's current minimum
  versions for cffi, certifi, and curl-impersonate. The package uses only the
  official PyPI sdist; no vendored dependency archive is hosted.
- Refreshed the downstream patch for 0.15.0. Linux builds select dynamic
  linking, do not call the upstream archive downloader, and do not inspect or
  link the static archive path. The PyPI sdist's generated curl headers are
  retained because the system curl-impersonate package intentionally removes
  its development headers.
- Replaced the undeclared, uncollectable full test suite with 59 focused
  upstream cookie, header, CLI parsing, output, doctor, and help tests. The
  ebuild tests the staged wheel rather than the source tree and disables
  unrelated pytest configuration/plugins. All 59 tests pass under Python 3.13
  and 3.14. The full suite remains unsuitable because Gentoo lacks several of
  its pinned/test-only dependencies, including proxy.py and litestar.
- A clean network-sandboxed Portage build/install passed for Python 3.13 and
  3.14 against a separately staged curl-impersonate 1.5.6. CLI help and doctor
  checks pass, and real loopback HTTP requests returned the expected response
  on both interpreters.
- The staged `_wrapper.abi3.so` needs the system
  `libcurl-impersonate.so.4` and libc only, has no RPATH/RUNPATH, textrels, or
  executable stack, and the wheel contains no static archive or bundled
  libcurl. All dependencies resolve when the staged system library is present.
- The current curl-impersonate ebuild does not enable ngtcp2/nghttp3, so doctor
  correctly reports HTTP/2 but not HTTP/3. That optional library capability is
  separate from curl-cffi packaging and is not replaced with a static bundle.
  Pkgcheck's remaining results are the package-wide missing `metadata.xml`
  tracked in Issue 25 and the intentionally deferred Python 3.15 suggestion.

### Issue 18 — wtype build-system dependency and reproducibility

Affected: `gui-apps/wtype/wtype-0.4.ebuild`.

- Declares CMake in BDEPEND although upstream uses Meson.
- Missing `dev-util/wayland-scanner` required by protocol generation.
- Upstream build conditionally reads Git and embeds `__DATE__`, making output
  dependent on host state/time. Patch or provide deterministic version/date.

Resolution:

- Verified that upstream v0.4 (tag commit
  `d71be3a7b3f93b534a2823fd68cabd7ac2a02359`) remains the latest release and
  that its release archive still matches the existing Manifest.
- Replaced the incorrect CMake build dependency with
  `dev-util/wayland-scanner` for the bundled protocol generation and
  `virtual/pkgconfig` for Meson's Wayland/xkbcommon dependency discovery.
- Added a patch that removes Git, branch, and `__DATE__` probing and always
  defines `VERSION` from `meson.project_version()` (`0.4`). This also prevents
  an enclosing, unrelated Git worktree from affecting the build.
- `VERSION` is not referenced by wtype 0.4's C source, so the original date did
  not enter the normal stripped binary. The build configuration was still
  host/time-dependent, could leak into debug macro information, and was fragile
  if upstream began using the existing define.
- Removed the no-op `src_configure` override and kept the Meson eclass default.
- Upstream ships no test suite; validation therefore covers configuration,
  compilation, installation, ELF QA, the installed man page, and a two-build
  reproducibility comparison.
- A clean Portage build found pkg-config, `wayland-scanner`, Wayland 1.25.0, and
  libxkbcommon 1.13.2; generated both protocol outputs; and installed the PIE,
  README, and man page. The binary has no executable stack or RPATH/RUNPATH,
  and all shared-library dependencies resolve.
- Builds from different paths and source mtimes, with one source nested beneath
  an unrelated `host-v9`/`host-branch` Git repository, produced byte-identical
  binaries (`fd557c8f6efcd8f27d66f346d34b949c7bbfa05b7c9ca679fff6e285b28bd2c4`).
  Both compile graphs contain only `-DVERSION="0.4"` and no Git/date value.
- `pkgcheck scan -v`, Manifest verification, `git diff --check`, the no-argument
  usage path, and invalid-modifier parsing all pass as expected.

### Issue 19 — hyprdynamicmonitors embeds wall-clock build time

Affected: `gui-apps/hyprdynamicmonitors-1.4.0.ebuild:35`.

- `date -u` is inserted into linker flags, defeating reproducible builds.
- Use a deterministic release timestamp or omit the field.
- Header says distributed under MIT rather than the standard overlay/Gentoo
  GPL-2 ebuild boilerplate.

Resolution:

- Verified that v1.4.0 remains upstream's latest release. Its tag resolves to
  commit `693e68b2a59d784bb8723bb9ed57a79cc60ca4f0`, dated
  `2025-12-01T15:10:38Z`.
- Replaced the wall-clock `date` invocation with that immutable tag-commit
  timestamp and replaced the misleading `cmd.Commit=gentoo` value with the
  actual upstream short commit, `693e68b`. These fields now retain upstream's
  intended version-reporting semantics without depending on build time.
- Restored the standard Gentoo GPL-2 ebuild boilerplate. This governs the
  ebuild itself; the packaged upstream program remains correctly declared MIT.
- The first clean build exposed two related QA issues: `go.mod` requires Go
  1.25, while the eclass default was older, and upstream's release flags
  pre-stripped the executable. Added `>=dev-lang/go-1.25.0` to BDEPEND and
  removed `-s -w` so Portage controls stripping and debug information.
- The custom `src_unpack` bypassed the EAPI-8 `go-module` compile-environment
  setup. Added an explicit `src_configure` call to restore the eclass's PIE,
  architecture, cache, toolchain, and `-buildvcs=false` controls.
- Once pre-stripping was removed, Go's debug information exposed absolute
  source paths and builds in two directories differed. Added `-trimpath`; two
  clean builds with separate caches are now byte-identical while retaining
  Portage-managed debug information.
- Validation covers the full vendored Go test suite, version output, generated
  bash/zsh/fish completions, a clean Portage install, ELF QA, `pkgcheck`, and a
  two-build byte-for-byte reproducibility comparison.
- Upstream's unit scope (`go test ./internal/...`) and binary-backed integration
  scope (`go test ./test/...`) pass outside the sandbox, where their local Unix
  sockets and session D-Bus fixtures are available. No module download occurs.
- With all completion USE flags enabled, the staged executable reports
  `1.4.0 (commit 693e68b, built 2025-12-01T15:10:38Z)` and generates nonempty
  bash, zsh, and fish completion files. The installed tree also contains both
  user services and all shipped themes.
- The final binary is PIE, has a non-executable stack, no RPATH/RUNPATH, and
  resolves its sole shared-library dependency. `go version -m` confirms
  `-buildmode=pie` and `-trimpath=true`.
- Two clean Portage compiles in different build directories with separate Go
  caches produced identical unstripped binaries
  (`6ad0ca5c91b65da6bcc599fe75c1d03677df21459734bc10d624b4300b3732fc`).
  The final build emits no Go-version or pre-stripping QA notice, and
  `pkgcheck scan -v` plus `git diff --check` pass.

### Issue 20 — materialyoucolor invalid RESTRICT

Affected: both `dev-python/materialyoucolor` ebuilds.

- `RESTRICT="network-sandbox"` is invalid and flagged UnknownRestrict.
- Evaluate Python 3.15 only after upstream support/testing; pkgcheck's compat
  suggestion is not sufficient evidence.

Resolution:

- Upstream released v3.0.3 on 2026-07-15 after the original audit. Replaced
  3.0.2 with the official v3.0.3 release sdist and retained the live ebuild.
- Removed the invalid `RESTRICT="network-sandbox"` from both ebuilds. Their
  import and upstream regression checks do not require external network access.
- Added the missing `>=dev-python/pybind11-2.11.0` build dependency declared by
  `pyproject.toml` and the `pillow` runtime dependency declared by package
  metadata. The regression script's test-only `psutil` and `rich` dependencies
  are also explicit.
- Extended testing beyond the installed-package import check to run upstream's
  included `tests/test_all.py`, which exercises the compiled C++ quantizer and
  the v3.0.3 temperature-cache regression without downloading data.
- The full installed-module import sweep exposed an upstream defect present in
  both v3.0.3 and current `main`: `theme_utils.py` imports the nonexistent
  `materialyoucolor.utils.string_utils` solely for an unused name. Added a
  minimal patch removing that import and applied it to stable and live.
- Retained Python 3.12 through 3.14. Upstream declares Python 3.7 or newer and
  the current Gentoo pybind11/Pillow versions support 3.15, but no Python 3.15
  interpreter is installed for an actual extension build and test; the pkgcheck
  suggestion alone remains insufficient evidence.
- Updated both ebuild copyright years to 2026.
- A final clean Portage build, test, and install passes for the installed
  Python 3.13 and 3.14 implementations. The import sweep covers every staged
  module, upstream's regression script passes for both implementations, and
  both compiled quantizer extensions have non-executable stacks, full RELRO,
  resolved shared-library dependencies, and no RPATH/RUNPATH. `pkgcheck` is
  clean apart from the intentionally deferred Python 3.15 suggestion.

### Issue 21 — hipSPARSELt deprecated eclass

Affected: 7.1.0 and 7.2.0.

Status: deferred for future work on 2026-07-17 at the maintainer's request.
The ROCm package set needs broader repair and is intentionally outside the
current continuation queue.

- Inherits deprecated `llvm-r1`; migrate to `llvm-r2` with testing.
- Update source to ROCm 7.2.4.

### Issue 22 — unconditional kernel-module autoloading

Status: fixed and verified as `ec-su_axb35-0_p20260711` and
`ryzen_smu-0.1.7_p20260425-r1`.

- Removed both packaged `/usr/lib/modules-load.d` entries. The two modules now
  follow policies appropriate to their actual hardware detection rather than
  being loaded unconditionally at boot.
- `ec_su_axb35` has no ACPI, DMI, PCI, or other module device table. Its init
  function immediately creates its interfaces, starts a once-per-second worker,
  and reads fixed embedded-controller registers without checking the board.
  The ebuild therefore leaves loading entirely to the administrator and emits
  a post-install warning with explicit `modprobe` and local
  `/etc/modules-load.d` instructions for confirmed Sixunited AXB35-02 systems.
- Added `CONFIG_CHECK="ACPI_EC"` to `ec-su_axb35`, matching the kernel
  `ec_read()` and `ec_write()` interfaces used by the driver.
- Updated `ec-su_axb35` to upstream commit
  `7a9f372edcaa99e562dece70204c4f609692a778`, dated 2026-07-11, and removed
  the three superseded snapshots. The new upstream commit changes only the
  optional Python GUI's Tk worker handling; the packaged kernel driver and
  monitor are unchanged from the prior snapshot.
- `ryzen_smu` already defines `MODULE_DEVICE_TABLE(pci, ...)`. The built module
  exposes 13 AMD PCI aliases, allowing the normal kernel/udev modalias path to
  load it only for matching hardware. Its redundant unconditional boot entry
  was removed, and `CONFIG_CHECK="PCI"` now declares the facility required by
  its PCI driver and configuration-space access.
- Upstream `ryzen_smu` remains at commit
  `0bb95d961664c7a0ac180f849fa16fe7da71922d` from 2026-04-25, so the current
  snapshot was revision-bumped for the packaging change and the older snapshot
  was removed. Its source archive uses a revision-independent distfile name.
- Retained `~x86` for `ryzen_smu`. Source review found no `X86_64` requirement;
  its CPUID and PCI interfaces exist on both x86 kernel architectures, and
  Gentoo's existing `app-admin/ryzen_smu` also supports x86. The original audit
  suggestion to remove the keyword was not supported by the implementation.
- No minimum-kernel version was added: neither upstream declares one, both
  modules build on the current supported kernel interfaces, and
  `ec_su_axb35` contains an explicit compatibility branch around the Linux 6.4
  `class_create()` API change. A speculative minimum would not improve QA.
- Clean Portage builds and staged installs passed for both modules against
  Linux 7.1.3 with GCC 16. The eclass validated both new `CONFIG_CHECK` values,
  stripped and signed the modules, and installed no `modules-load.d` files.
  The staged modules are non-executable-stack ET_REL objects; `modinfo`
  confirmed no alias for `ec_su_axb35` and all 13 expected PCI aliases for
  `ryzen_smu`. The automatically generated dracut configuration uses
  `omit_drivers` for both modules unless initramfs inclusion is explicitly
  enabled. Final `pkgcheck`, metadata XML validation, Manifest verification,
  and `git diff --check` pass.

### Issue 23 — Azure CLI bundled license declaration

Affected: all `app-admin/azure-cli-bin` ebuilds.

- Resolved on 2026-07-17 by maintainer decision and the
  `azure-cli-bin-2.87.0-r1` packaging revision. The broader bundled-license
  declaration was deliberately not applied: the maintainer requested that
  `LICENSE="MIT"` remain unchanged. This records a policy decision, not a
  finding that every bundled work is MIT-licensed.
- The official Noble Debian artifact is a self-contained `/opt/az` bundle
  containing a private CPython 3.13 runtime. Its 168 `.dist-info/METADATA`
  records and embedded notice files identify licenses including Apache-2.0,
  BSD variants, ISC, LGPL variants, MIT, MPL-2.0, and PSF-2. The Debian
  `copyright` file itself declares the aggregate package MIT and does not
  enumerate those bundled works.
- The revision preserves the Debian `copyright` and changelog under the
  installed package documentation and generates a deterministic
  `bundled-packages.txt` inventory. The inventory includes name, version,
  declared license, and bundle location for all 168 distributions, including
  the 12 distributions nested under setuptools' `_vendor` directory.
- Runtime dependencies now match the Debian control metadata and a complete
  ELF `DT_NEEDED` scan: bzip2, libffi.so.8, OpenSSL 3, glibc 2.38 or newer,
  libuuid, a libgcc provider, and zlib. `REQUIRED_USE="elibc_glibc"` prevents
  selection on musl profiles. The Ubuntu Python bzip2 extension's
  `libbz2.so.1.0` dependency is rewritten to Gentoo's ABI-equivalent
  `libbz2.so.1` SONAME during `src_prepare`.
- Superseded 2.84.0, 2.86.0, and unrevisioned 2.87.0 ebuilds and their
  Manifest entries were removed. The official upstream latest release was
  rechecked as 2.87.0; the earlier 2.88.0 audit-table entry was incorrect.
- Verification covered Manifest hashes, a clean staged Portage install with
  no install QA notices, exact 168/168 inventory reconciliation, retained
  documentation and completion files, the rewritten bzip2 dependency, and
  an offline staged-runtime invocation reporting Azure CLI 2.87.0. Ebuild
  syntax, metadata scan, and `git diff --check` also pass; `pkgcheck` only
  reports the expected `RequiredUseDefaults` result for musl profiles that
  cannot satisfy this upstream glibc binary.

### Issue 24 — Bibata old Manifest mismatch and stale wrapper

Status: fixed on 2026-07-17 by replacing the old single-theme package and
versioned wrapper with a generic all-variants package maintained in this
overlay.

- Deleted `x11-misc/bibata-modern-classic`, including the shadowed 2.0.6-r1
  ebuild, current 2.0.7 ebuild, and invalid old Manifest entry. Deleted the
  redundant `app-misc/illogical-impulse-bibata-modern-classic-bin` wrapper.
- Vendored `x11-themes/bibata-xcursors-2.0.7` from GURU into nekochigura and
  assigned it to the local maintainer. It continues to fetch the official
  upstream release archive directly, so no release artifact is hosted by the
  overlay.
- `app-misc/illogical-impulse-1.0-r1` now depends directly on
  `x11-themes/bibata-xcursors`. The revision bump ensures existing master
  metapackage installations receive the dependency change. The supplied
  package-accept-keywords configuration and Illogical Impulse README use the
  generic atom and no longer reference either deleted package.
- The vendored 2.0.7 ebuild tracks the current official Bibata release and
  installs all 12 Modern and Original variants. A clean staged Portage install
  produced no QA notices. Its `Bibata-Modern-Classic` directory contains the
  same 58 files, byte-for-byte, as the laptop's former custom 2.0.7 package, so
  the configured cursor theme is preserved after migration.
- The laptop was actively using the deleted custom 2.0.7 package through both
  `XCURSOR_THEME` and the GNOME cursor setting. After the replacement content
  was verified, the custom package was removed and GURU's
  `x11-themes/bibata-xcursors-2.0.7` was installed and recorded in the world
  set. It was then reinstalled from nekochigura after the ebuild was vendored.
  The old atom is no longer installed, both settings remain
  `Bibata-Modern-Classic`, and its content still exactly matches the
  pre-migration backup.
- Targeted `pkgcheck` returns no reports for both the vendored package and the
  revised master metapackage. Reference scans, Manifest and metadata
  validation, clean staged installs, and `git diff --check` pass.

### Issue 25 — miscellaneous metadata and policy cleanup

Status: fixed on 2026-07-17 as a metadata and non-functional policy cleanup.
Version updates, keyword/dependency changes, and redundant-version pruning were
deliberately kept out of this issue.

- A fresh scan of this checkout found that MicroTeX and Quickshell metadata had
  already been added by Issues 2 and 9. Added the 16 metadata files that were
  actually absent, covering every remaining package directory. Added 14
  upstream remote IDs across 13 packages; the two Ollama account objects and
  proprietary DisplayLink package correctly have no independent forge ID.
- Documented all nine overlay-local USE flags: the seven IPU6 Camera HAL build
  options, v4l2-relayd's IPU6 integration, and curl-impersonate's optional
  browser-specific clients.
- Corrected all seven Talosctl descriptions and shortened their repeated source
  URI definitions without changing resolved URLs. Added the standard Gentoo
  copyright/license boilerplate to all 19 ebuilds that lacked it, including
  Talosctl, the IPU6 stack, and video-compare. Talosctl remains queued
  separately for a version update.
- Cleared the repository's safe style findings across 43 ebuilds: empty
  assignments, variable ordering, trailing blank lines, leading-space
  indentation, terminal description punctuation, excessive line lengths,
  inconsistent tar syntax, and completion-eclass usage. The changes are
  non-functional and require no package revision bumps.
- Removed the redundant short FIDO group long description. All newly added XML
  validates, every changed ebuild passes shell syntax validation, and targeted
  pkgcheck reports no remaining missing metadata/remote IDs, undocumented USE
  flags, unsafe whitespace, ordering, line-length, empty-assignment,
  description, inherit, or tar-syntax result.
- The v4l2-relayd `BetterCompressionUri` suggestion is intentionally retained:
  switching GitLab archive formats changes the fetched artifact and belongs in
  a separately tested package update. `images`, `illogical-impulse`, and the
  `nekochigura-dependencies` submodule are intentional repository support
  directories, accounting for the single `UnknownCategoryDirs` result.
- The first scan accidentally resolved the configured stale checkout at
  `/home/czl/projects/nekochigura`. All authoritative verification was rerun
  against `/home/czl/nekochigura` by absolute path with an isolated cache.

### Issue 26 — Talosctl update and shadowed versions

Status: fixed on 2026-07-17 with `talosctl-bin-1.13.6`.

- Rechecked the official immutable GitHub release: v1.13.6, released
  2026-07-09, remains marked latest. The release tag resolves to signed commit
  `04318854e` and provides Linux binaries for all three overlay keywords.
- Replaced 1.13.3 with 1.13.6 and removed the six older, fully shadowed ebuilds
  from the 1.12 and 1.13 series. The Manifest now contains only the amd64,
  arm64, and armv7 v1.13.6 assets instead of 21 historical binaries.
- Downloaded all three binaries and the official SHA-256 and SHA-512 lists.
  Every asset matched both official checksums and the generated Manifest.
  ELF inspection identified the expected x86-64, AArch64, and 32-bit ARM EABI5
  statically linked executables.
- Added `RESTRICT="strip"` after the first staged install exposed Portage
  re-stripping the already stripped upstream Go binary. The final clean staged
  amd64 install emits no QA notice, is byte-identical to the checksum-verified
  release asset, and reports `Talos v1.13.6` through its client version command.
- Talosctl is not installed on the laptop, so no live package migration was
  required. Ebuild syntax, metadata XML, targeted pkgcheck, Manifest,
  repository-wide pkgcheck accounting, and `git diff --check` pass.

### Issue 27 — Google Cloud CLI update and redundant versions

Status: fixed on 2026-07-17 with `google-cloud-cli-576.0.0`.

- Rechecked Google's release notes, install documentation, and rapid-channel
  manifest. Version 576.0.0, released 2026-07-14, is current. It changes
  `gcloud storage rsync` to decompress downloaded gzip objects by default
  unless `--do-not-decompress` is used. It also refreshes bundled Linux Python
  to 3.14.6 for CVE-2026-34182; the ebuild removes bundled Python and uses the
  selected Gentoo interpreter instead.
- Downloaded both immutable versioned archives. They contain internal
  `VERSION` 576.0.0 and the expected 64-bit static `gcloud-crc32c` binaries:
  x86-64 for amd64 and AArch64 for arm64. The x86 archive is 88,267,839 bytes
  with SHA-256
  `7094a08e8fc3772cdbfb1a8a1920300f52fec5e370c9f9c803c2a3c8824a32c2`;
  the Arm archive is 61,127,594 bytes with SHA-256
  `be6077ade7b08312a250b49b5838473253c52e25358c63cfb2cfb4095503b5f2`.
  Their generated BLAKE2B/SHA-512 Manifest entries were independently
  reproduced.
- Google's install page publishes SHA-256 values for the rolling unversioned
  filenames, whose gzip headers differ from the immutable versioned objects by
  eight bytes. Those moving-file hashes were therefore not misapplied to the
  ebuild distfiles. The versioned objects were additionally verified through
  Google's canonical Cloud Storage object sizes, generations, MD5 metadata,
  valid gzip/tar structure, and embedded version.
- Replaced 567.0.0 with 576.0.0 and removed fully shadowed 558.0.0 and 561.0.0
  as well. The Manifest now has only the two 576.0.0 architecture archives
  rather than six historical artifacts.
- Corrected package-manager ownership: upstream's supported
  `disable_updater` switch is enabled, so routine commands no longer advertise
  updates and `gcloud components update` refuses before changing the
  Portage-owned tree.
- Made `PYTHON_SINGLE_TARGET` authoritative in all six shell launchers while
  preserving explicit `CLOUDSDK_PYTHON`, `CLOUDSDK_BQ_PYTHON`, and
  `CLOUDSDK_GSUTIL_PYTHON` overrides. Clean staged builds selected Python 3.13
  and 3.14 correctly. Python 3.15 was not added because upstream supports only
  Python 3.10 through 3.14.
- Limited shebang rewriting to the four Python entry points under `bin`, so
  gsutil's source tree is not modified. Its self-checksum now reports `OK`.
  Bytecode compilation is limited to the active gcloud bootstrapping, core,
  and command-surface trees, avoiding syntax errors from bundled Python 2
  compatibility and test sources.
- The old `alpha` local USE flag collided with Gentoo's Alpha architecture flag
  and was discarded on amd64. Renamed the two options to `alpha-commands` and
  `beta-commands`; both were observed in Portage's recorded USE state and both
  loaded real `gcloud ... firebase test --help` command surfaces. With the
  flags disabled, the external-package-manager guard refuses component
  installation as intended.
- Replaced the incomplete Apache-only declaration with the retained runtime's
  cumulative `Apache-2.0 BSD BSD-2 ISC LGPL-2.1+ MIT MPL-2.0 PSF-2
  public-domain` licenses. Non-runtime tests, documentation, examples, a
  PyInstaller hook, and charset-normalizer sample corpora were pruned to avoid
  distributing irrelevant or ambiguously licensed fixtures. The complete
  `lib/googlecloudsdk`,
  `lib/surface`, and self-checksummed `platform/gsutil/gslib` runtime boundaries
  are deliberately preserved because their test-named paths implement real
  installed commands.
- Narrowed `QA_PREBUILT` to the sole retained ELF,
  `usr/share/google-cloud-sdk/bin/gcloud-crc32c`. Final staged QA found no
  broken `/usr/bin` links, bundled Python, unexpected bytecode tags, RPATH, or
  extra ELF files. `gcloud version`, `gcloud info`, `bq version`, `gsutil
  version -l`, both optional tracks, updater refusal, ebuild syntax, metadata
  XML, Manifest, and `git diff --check` pass. The laptop remains on its existing
  world-selected 567.0.0 until its configured overlay checkout is updated; no
  real `~/.config/gcloud` data was touched during testing.

### Issue 28 — Moomoo update and binary-runtime repairs

Status: fixed and verified on 2026-07-17 with `moomoo-bin-16.24.16908`.

- Rechecked the live official Linux release state rather than relying on the
  search index, which was one release stale. Stable (non-beta) 16.24.16908 was
  released 2026-07-16 with bug fixes and performance improvements. The page
  lists Ubuntu 18.04 or newer, 369.11 MB, and only the amd64 Debian package;
  the plausible arm64, aarch64, and x86_64 filename variants return 404.
  `~amd64` is therefore retained as the only keyword.
- Downloaded the immutable vendor-CDN object directly. It is 387,038,448 bytes,
  has a clean Debian ar structure and control version/architecture, and its MD5
  `6d42a18451d4103154e1f82c21da6aac` matches the CDN ETag. Locally reproduced
  hashes are SHA-256
  `526dece68464ddab0940f8ddb876f51570f5040e16e8d296438604558b504e1c`,
  BLAKE2B
  `9ad90df6ffecfff95c2d274a95f64f662f28cb25ce208773bb1535d25c9f2f1410fc737f380be692e4d3544ddc759288af97ca32a5fbba91f5070031c1d46506`,
  and SHA-512
  `539237ffec3d684b596a69878c11d7169c6fe223297c0f4afed7567102764111fe9ce03823bf4bc0b56f6c001edcb6bc76c111cf30400500a1face0b2e84847c`.
  Upstream publishes no SHA checksum or detached/embedded signature; the
  Manifest uses the verified clean object. A separate interrupted temporary
  download with trailing garbage was rejected and never used.
- The official terms grant only a limited personal-use application license and
  prohibit redistribution and modification outside the stated exceptions.
  The payload files named `license.txt` are third-party notices, not a license
  for Moomoo itself. `LICENSE="all-rights-reserved"` and
  `RESTRICT="bindist mirror strip"` remain correct, and the archive continues
  to be fetched from the vendor rather than mirrored or vendored.
- Replaced the old `doins` plus partial chmod sequence with a mode-preserving
  install and explicit root ownership. The old ebuild silently installed the
  bundled `python3` and `NNPython` quant entrypoints as non-executable even
  though upstream ships them as 0755. All retained upstream executable bits
  now survive the staged install. The old 16.18.16308-r1 ebuild and distfile
  entry were removed after the replacement passed.
- Removed the overlay's unnecessary setuid grant from `chrome-sandbox`.
  Upstream ships and installs the helper as ordinary 0755, so the staged image
  now contains a root-owned 0755 helper rather than granting a proprietary
  binary setuid-root privileges.
- Completed the runtime dependency closure for the bundled Qt 5, CEF,
  multimedia, XCB, Python 3.8, and image-plugin stack. This includes the
  precise Gentoo compatibility providers for OpenSSL 1.1, libffi.so.6,
  ncurses ABI 5, libtiff.so.5, Berkeley DB 5.3, and Tcl/Tk 8.6. The system
  `libstdc++`/`libgcc_s` substitution remains necessary because upstream's
  compiler runtime stops at `GLIBCXX_3.4.30`; the final loader trace selects
  Gentoo's current libraries. `REQUIRED_USE="elibc_glibc"` makes the vendor
  binary's libc requirement explicit.
- Sanitized every vendor RPATH/RUNPATH to retain only deduplicated
  `$ORIGIN`-relative entries, removing current-directory, empty, and leaked
  Jenkins build-host paths. Cleared the unnecessary executable-stack request
  from `CrashReporter`; the final tree has no executable stack or text
  relocation. Retargeted Python's bzip2 module from Ubuntu's
  `libbz2.so.1.0` spelling to Gentoo's ABI-equivalent `libbz2.so.1`. The
  optional `_gdbm` and `readline` extensions were removed because no current
  Gentoo compatibility package provides their obsolete SONAMEs; this avoids
  claiming false dependencies for modules that could not load before.
- A final clean unpack/prepare/install cycle succeeds. Its only unresolved
  SONAME notice reflects compatibility packages declared in `RDEPEND` but not
  installed on the build host; every remaining item maps to the declared
  OpenSSL, ncurses, Berkeley DB, Tcl/Tk, or TIFF compatibility atom. Dependency
  resolution selects those packages correctly for a real merge.
- Static validation confirms root ownership, a 0755 sandbox helper, preserved
  Python/quant executable modes, only x86-64 ELFs, no bundled compiler runtime,
  no insecure RPATH, no executable stack, and no text relocations. The staged
  Python 3.8 runtime imports JSON, lzma, sqlite3, zlib, and the patched bzip2
  module successfully. An unprivileged, network-isolated Moomoo launch loads
  the private Qt XCB plugin and all of its system libraries, then reaches the
  expected `could not connect to display :99` failure because no virtual X
  server is installed. No real Moomoo profile or brokerage session was used.
- The laptop's world-selected 16.18.16308-r1 installation passes `qcheck`, and
  no Moomoo process was running during the audit. It was deliberately not
  upgraded live; publication updates the overlay only. Targeted pkgcheck has
  only the intentional musl-profile `elibc_glibc` report; the repository-wide
  summary below includes that additional result.

## Automated pkgcheck summary

Repository-wide non-network scan counts:

| Count | Check |
|---:|---|
| 57 | RedundantVersion |
| 6 | PythonCompatUpdate |
| 6 | NonsolvableDepsInStable |
| 6 | NonsolvableDepsInDev |
| 5 | PotentialStable |
| 3 | MatchingChksums |
| 2 | DeprecatedEclass |
| 1 | UnknownCategoryDirs |
| 2 | RequiredUseDefaults |
| 1 | BetterCompressionUri |

Most of the originally reported 107 redundant versions are fully shadowed
older point releases.
Prune them per package after the newest replacement builds successfully, unless
there is an intentional rollback/security/channel reason to retain them.

Notable redundant groups include older 1Password, Azure CLI, Passless,
SongRec, Bun, Coder, Ghidra, OpenCode,
Fuzzel, Hyprmon, Hyprsunset, wlogout, XDPH, Breeze Plus, Twemoji, video-compare,
curl-impersonate, Clash Party, RyzenAdj, EVDI, adw-gtk3, Catppuccin Neovim,
Darkly, Ollama, and Ollama-bin versions.

## Packages with no substantive defect found in their current ebuild

This means no blocker beyond update/ordinary cleanup was identified; it does
not substitute for a build test:

- `acct-group/fido`, `acct-group/ollama`, `acct-user/ollama`
- `app-crypt/picoforge`
- `app-misc/brightnessctl`
- local `app-misc/caelestia` meta
- `dev-embedded/rkdeveloptool`
- `dev-python/materialyoucolor` apart from invalid RESTRICT
- `gui-apps/fuzzel`, `gui-apps/nwg-displays`, `gui-apps/wlogout`
- `gui-libs/xdg-desktop-portal-hyprland`
- `media-fonts/space-grotesk`, `media-fonts/twemoji` apart from update/pruning
- `media-sound/libcava`
- `media-video/v4l2-relayd` apart from minor metadata/USE cleanup
- `sys-auth/howdy`
- `sys-power/RyzenAdj`
- `x11-drivers/evdi`
- `x11-libs/libxcb`
- `x11-misc/matugen`
- `x11-themes/adw-gtk3`, `catppuccin-neovim`, `qtengine`

## Safe continuation point

1. Keep hipSPARSELt and the wider ROCm package set deferred for future work.
2. Present the next upstream package update as a separate proposal and wait for
   permission.
3. Continue strictly one issue at a time, including signed publication and
   cleanup before advancing.
