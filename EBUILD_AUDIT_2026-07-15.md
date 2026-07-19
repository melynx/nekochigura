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

## Gaze snapshot moved from the stale checkout

On 2026-07-18, the only unfinished work in the stale
`/home/czl/projects/nekochigura` checkout was copied here unchanged before that
checkout was removed. They were then reviewed and completed as Issue 38:

- `sys-auth/gaze/gaze-0.2.4_p20260716.ebuild` was an untracked testing snapshot
  pinned to `melynx/gaze` commit
  `6236a62361399dcdf990ca6e468da80cf0e8c185`;
- `sys-auth/gaze/Manifest` added that snapshot archive and the eight
  replacement crate versions required by its lockfile.

The transferred snapshot added a Rust 1.96 minimum, used the existing three
local security patches, and reloaded systemd plus tried to restart `gazed`
after installation. Issue 38 replaced it with an official-upstream snapshot,
removed the older release, narrowed the restart to real upgrades, and completed
the required build and package checks.

The stale checkout also had local commit `ed614ce`, but every file from that
commit already matched this repository exactly. It was not copied or replayed.

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

The restored archives at that point were:

- `gui-apps/hyprdynamicmonitors/hyprdynamicmonitors-1.4.0-vendor.tar.xz`
- `gui-apps/hyprmon/hyprmon-0.0.12-vendor.tar.xz`
- `gui-apps/hyprmon/hyprmon-0.0.15-vendor.tar.xz`

Issue 32 later switched HyprMon to official upstream release binaries and
purged both HyprMon vendor archives from the dependency repository's complete
history. The HyprDynamicMonitors archive remains referenced.

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
| `app-admin/ryzen_smu` | snapshot 20260626 / `1be4fb1` | same HEAD found | Current after Issue 29. https://github.com/amkillam/ryzen_smu/commit/1be4fb1cd9d60b5ddefc2a4201a898766a731400 |
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
| `dev-util/coder-bin` | stable 2.34.6; testing 2.35.2 | stable 2.34.6; mainline 2.35.2 | Both verified channels current after Issue 30. https://github.com/coder/coder/releases/tag/v2.34.6 and https://github.com/coder/coder/releases/tag/v2.35.2 |
| `dev-util/ghidra-bin` | 12.1.2 | 12.1.2 | Current after Issue 31. https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.2_build |
| `dev-util/opencode-bin` | 1.18.2 | 1.18.2 at resolution | Current after Issue 8. https://github.com/anomalyco/opencode/releases/tag/v1.18.2 |
| `gui-apps/caelestia-shell` | snapshot 20260716 / `dbb6d6c` | same HEAD at resolution | Current after Issue 14. https://github.com/caelestia-dots/shell/commit/dbb6d6c029021145422255dee6cd7ba607be3a20 |
| `gui-apps/hyprmon` | 0.0.17 | 0.0.17 | Current after Issue 32. https://github.com/erans/hyprmon/releases/tag/v0.0.17 |
| `gui-apps/hyprsunset` | 0.4.0 | 0.4.0 | Current after Issue 33. https://github.com/hyprwm/hyprsunset/releases/tag/v0.4.0 |
| `kde-plasma/breeze-plus` | 6.28.0 | 6.28.0 | Current after Issue 34. https://github.com/mjkim0727/breeze-plus/releases/tag/6.28.0 |

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
| `material-symbols-variable` | snapshot 20260717 / `abd7f5c0` | same variable-font HEAD at resolution | Current after Issue 35. https://github.com/google/material-design-icons/commit/abd7f5c0e179c83f068c770650bd14ebac5d5a09 |
| `twemoji` | 17.0.3 | 17.0.3 | Current after Issue 36. https://github.com/jdecked/twemoji/releases/tag/v17.0.3 and https://github.com/JoeBlakeB/ttf-twemoji/releases/tag/17.0.3 |
| `ipu6-camera-hal` | `20260629_2` | `20260629_2` | Current after Issue 37. https://github.com/intel/ipu6-camera-hal/tags |
| `ipu6-camera-bins` | `20260629_2` | `20260629_2` | Current and aligned with the HAL after Issue 37. https://github.com/intel/ipu6-camera-bins/tags |
| `gst-plugins-icamerasrc` | `20260629_1` | `20260629_1` | Current after Issue 6. https://github.com/intel/icamerasrc/tags |
| `ipu6-drivers` | `20260629_2` | `20260629_2` | Current after Issue 39. https://github.com/intel/ipu6-drivers/releases/tag/20260629_2 |
| `gpu-screen-recorder` | 5.15.1 plus live 9999 | 5.15.1 | Current after Issue 40. https://git.dec05eba.com/gpu-screen-recorder/refs/ |
| `makemkv` | 1.18.4 | 1.18.4 | Current after Issue 7. https://www.makemkv.com/download/ |
| `video-compare` | 20260708 | 20260708 | Current after Issue 41. https://github.com/pixop/video-compare/tags |
| `wechat-bin` | 4.1.1.8 | 4.1.1.8 at resolution | Current with immutable artifact after Issue 4. https://linux.weixin.qq.com/ |
| `clash-party-bin` | 2.0.0 | 2.0.0 | Current after Issue 42. https://github.com/mihomo-party-org/clash-party/releases/tag/v2.0.0 |
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

### Issue 29 — ryzen_smu snapshot update

Status: fixed and verified on 2026-07-17 with
`ryzen_smu-0.1.7_p20260626`.

- Pinned the newest upstream `main` commit,
  `1be4fb1cd9d60b5ddefc2a4201a898766a731400`. The two commits after the old
  `0bb95d9` snapshot repair a false failure in `scripts/test.py` by dropping a
  trailing newline from its formatted expected version and document verified
  Ryzen AI 9 HX 370 / Strix Point PM-table support. The driver code path and
  advertised module version remain unchanged; the C edits are comments on
  already-existing model and PM-table cases.
- The immutable GitHub snapshot archive is 414,071 bytes. Its Manifest hashes
  are BLAKE2B
  `eb68379c81d247ff7a37babc784f9e2608989f83c934f908f9011ac6a928ac8e8bd4e306b7671fc0cab0880148facf3182f5e6f3b733f380157da25e267e7473`
  and SHA-512
  `8909727b4549c0da2434d77e9b85515562918b5b6ead6150e94182c0b6f61996b0cca9ba0272d288fc8dc2a7dd8b8f4db9d226fc7e8a6481b3c76f2a6e51e90f`.
  The shadowed 20260425-r1 ebuild and old distfile entry were removed.
- A clean unpack, prepare, compile, and staged install succeeds against the
  active `7.1.3-gentoo-dist` kernel sources with `CONFIG_PCI` enabled. The
  staged x86-64 `ryzen_smu.ko` reports GPL, upstream version 0.1.7, the
  expected AMD PCI aliases, retpoline support, and matching
  `7.1.3-gentoo-dist` vermagic. Upstream's corrected Python test script also
  passes bytecode compilation.
- The build warns that the installed distribution kernel was compiled with
  GCC 15 while the currently selected and only available module compiler is
  GCC 16. The module nevertheless compiles, links, signs, and stages
  successfully. This is a host kernel/toolchain synchronization warning, not
  an ebuild or upstream-source failure.
- Targeted pkgcheck is clean. No package was merged and no module was loaded;
  the live system has neither an installed `ryzen_smu` package nor a loaded
  `/sys/module/ryzen_smu`. The repeatable authoritative full-tree scan reports
  62 `RedundantVersion` results; the earlier ledger value of 57 was corrected
  below and is unrelated to this single-version package.

### Issue 30 — Coder stable/mainline channels and binary license

Status: fixed and verified on 2026-07-17 with stable `coder-bin-2.34.6` and
testing `coder-bin-2.35.2`.

- Coder's official policy keeps the N-1 release line as stable and fields the
  newest line as mainline for a month before promotion. GitHub marks 2.34.6 as
  the current stable/ESR release and 2.35.2 as mainline. The overlay now keeps
  both: 2.34.6 uses `KEYWORDS="amd64 arm64"`, while 2.35.2 uses
  `KEYWORDS="~amd64 ~arm64"`. This follows the same durable upstream-channel
  versus Gentoo-keyword policy already used for Claude Code. Coder's release
  schedule table still names the preceding 2.34.5/2.35.1 patches, but the
  newer immutable release records and channel-labelled notes establish the
  current versions; this is an upstream documentation lag.
- Both GitHub release records are non-prerelease, immutable objects published
  on 2026-07-14. The four verified Linux archives are:

  | Channel/architecture | Bytes | Upstream SHA-256 |
  |---|---:|---|
  | 2.34.6 amd64 | 182,802,349 | `091acfd4356ab2f02bcaf561928841e9aecc630a28bc9678658d4ae47632df09` |
  | 2.34.6 arm64 | 177,605,643 | `d16b0f9393404e1d85669ec620aa90d2a0c10b1977c11c95e11b2d6b9bb0917d` |
  | 2.35.2 amd64 | 188,518,634 | `907017ffefae1af67bd6533b6c9ddd6b975e39ea9ef9340deba3dc72231b209c` |
  | 2.35.2 arm64 | 182,834,303 | `12e4fbd607321cb2464a0625c021e8cfdcb109fe73d3c42c70cd86d7702796b5` |

  Locally reproduced SHA-256 values match both the signed upstream checksum
  lists and GitHub's release-asset digest metadata. Portage independently
  recorded BLAKE2B and SHA-512 hashes in the regenerated Manifest.
- Verified both detached checksum signatures outside the sandbox in an
  isolated GnuPG home using the `release.key` committed at each immutable tag.
  The two tagged keys are byte-identical, with SHA-256
  `df7de486a7d3a674ab58bb66e8522388022249dc6a7a7725b65256c86b577213`.
  Both signatures are cryptographically valid under Coder's RSA4096 release
  key `21C96B1CB950718874F64DBD6A5A671B5E40A3B9`, UID
  `Coder Release Signing Key <security@coder.com>`. GnuPG's `unknown` trust
  label is expected for the deliberately isolated keyring and is distinct
  from signature validity. Independent release verification also found both
  immutable-release and tagged-workflow SLSA attestations for every archive.
  The annotated git tags themselves are unsigned, although their target
  commits have valid GitHub signatures. Because upstream permits attestation
  generation to fail without failing its workflow, future updates must keep
  verifying each release rather than assuming an attestation exists.
- Fixed a pre-existing license defect discovered while auditing the update.
  Official release binaries are built from
  `github.com/coder/coder/v2/enterprise/cmd/coder`, and every archive contains
  both AGPLv3 and `LICENSE.enterprise` terms. Added its substantively verbatim,
  trailing-whitespace-normalized text as overlay license `Coder-Enterprise`,
  declared `LICENSE="AGPL-3 Coder-Enterprise"`, and installed the upstream
  README and Enterprise terms as package documentation. The license expressly
  permits copying and distribution subject to its conditions, so no
  `mirror`/`bindist` restriction is required; `RESTRICT="strip"` remains.
- All four payloads are already-stripped, CGO-disabled, statically linked Go
  executables with no interpreter, dynamic dependencies, RPATH, text
  relocation, or executable stack. They need no `RDEPEND`. The amd64 binaries
  use baseline `GOAMD64=v1`, and arm64 uses `GOARM64=v8.0`; no host-specific
  CPU selection occurs. `QA_PREBUILT="usr/bin/coder"` remains correct.
- Clean stable and mainline unpack/prepare/install cycles preserve the exact
  amd64 binary payload as root-owned 0755 and install the two compressed docs.
  Unprivileged network-isolated `coder version` runs succeed natively on amd64
  and through QEMU user mode for arm64 for both channels, reporting the exact
  tagged commits and confirming each is the full server-capable build. No
  server, login, database, user profile, or network connection was used.
- Removed the shadowed 2.30.3, 2.30.4, 2.31.11, and 2.32.5 ebuilds and their
  eight Manifest objects; upstream explicitly marks the 2.30, 2.31, and 2.32
  lines unsupported. Coder was neither installed nor running on the laptop,
  so no live package or service was changed. Targeted pkgcheck is clean; the
  full-tree redundant-version total falls from 62 to 59.

### Issue 31 — Ghidra 12.1.2 update, licenses, and installed modes

Status: fixed and verified on 2026-07-17 with `ghidra-bin-12.1.2`.

- Updated to the latest official non-prerelease release, tag
  `Ghidra_12.1.2_build` at commit
  `c0f584bf229fffba61b36431f3ce30c0c3e4e682`, published on 2026-06-05.
  The sole uploaded release asset, `ghidra_12.1.2_PUBLIC_20260605.zip`, is
  572,803,866 bytes. Its locally reproduced SHA-256 is
  `b62e81a0390618466c019c60d8c2f796ced2509c4c1aea4a37644a77272cf99d`,
  exactly matching GitHub's release-asset digest, and a complete ZIP
  integrity test passes. Portage records BLAKE2B
  `143df3c443552daf7f7d7d562c391d298733301f3cd9d1b9a06a526250306c213eaacb095d943abe7b852e67ed44669d6aa07146a9f522041334ef8d8cf62e76`
  and SHA-512
  `5d10c086ac1099fd2a63eb9417d8f12fcaad962292b3f4410e8ad356fd72875205772371dd9a6d789f721ca44f00025de3195420da746d4023bddec333c37246`.
- The official public build provides Linux x86-64 native binaries only, so
  the released package is stable-keyworded `amd64` and explicitly requires
  glibc. Its metadata specifies a 64-bit JDK 21 minimum with no maximum and
  Python 3.9-3.14 for debugger/PyGhidra support. Runtime linkage also makes
  the GCC runtime a direct dependency. The old 12.0.4 and 12.1 ebuilds and
  their Manifest objects were removed.
- Fixed a substantial pre-existing license defect. The top-level program is
  Apache-2.0, but 103 module manifests declare bundled BSD, GPL, LGPL, MIT,
  MPL, PostgreSQL, PSF, icon, public-domain, and other components. The
  CycloneDX SBOM has 203 components but no license fields and omits the
  nested Jython fat JAR. The ebuild now declares the complete audited set,
  including `CNRI-Jython` and `Ghidra-CPP`; their missing terms were added as
  overlay licenses from the canonical JPython license and Ghidra's tagged
  CPP parser notice. All applicable terms permit redistribution when their
  notices and supplied source are retained, so the unjustified `bindist` and
  `mirror` restrictions were removed. The installed license manifests,
  `licenses/`, `GPL/`, nested notices, and supplied source archives remain
  intact; only `strip` remains restricted because stripping the packaged
  training binaries would alter their instructional payload.
- Replaced the mode-destroying `doins -r` installation. The former installed
  12.1 tree is owned by `nobody:nobody`; it restored only a handful of
  launchers, leaving supported commands such as `support/bsim`,
  `support/ghidraDebug`, `support/sleigh`, `server/ghidraSvr`,
  `server/svrAdmin`, and debugger launchers non-executable. Conversely, its
  blanket shared-library chmod incorrectly made data libraries executable.
  The new install is root-owned, normalizes directories to 0755 and ordinary
  files to 0644, then restores exactly 67 semantic upstream executables:
  runtime/server/debugger/Docker launchers, BSim's setup helper, five Linux
  native commands, and 16 executable training samples. Together with the two
  overlay wrappers, the staged image has 69 executable regular files. This
  also clears erroneous executable bits from 68 upstream JAR, source, XML,
  manifest, and image files while retaining every supported launcher.
- Platform pruning now also removes the overlooked Windows x86-32 native
  directory and the separate macOS/Windows 7-Zip JNI payloads, in addition to
  macOS and Windows x86-64 runtime directories and batch launchers. Cross-target
  analysis data remains installed. All 22 remaining ELF files are little-
  endian x86-64: five operational native commands, the 7-Zip JNI library,
  and 16 training files. `QA_PREBUILT` now covers all 22 instead of only five.
  None has an executable stack, text relocation, RPATH, or RUNPATH; runtime
  requirements are limited to glibc and the GCC C++ runtime.
- A clean unpack/prepare/install cycle produces a root-owned image with no
  group/other-writable entries, no unsupported native platform payload, no
  batch files, valid wrapper syntax, valid metadata XML, and a valid desktop
  file. The previous unregistered `ReverseEngineering` desktop category was
  removed. Unprivileged, network-isolated commands against the staged image
  with a disposable home execute correctly under Java 25:
  `analyzeHeadless`, BSim, and Sleigh reach their expected usage output,
  while a foreground GUI launch
  reaches the expected no-display diagnostic. No project, user profile,
  server, network session, or live package was used.
- The laptop still has 12.1 installed and its file checksums pass, but its
  ownership and launcher modes exhibit the defects above; no Ghidra process
  was running during inspection. It was deliberately not upgraded live.
  Targeted pkgcheck reports only the intentional `RequiredUseDefaults` result
  on musl profiles for this glibc-only upstream binary. The authoritative
  full-tree summary now has 58 redundant versions and three such
  required-USE reports.

### Issue 32 — HyprMon 0.0.17 official binary update

Status: fixed and verified on 2026-07-17 with `hyprmon-0.0.17` for amd64 and
arm64.

- Updated from 0.0.15 to the latest official non-prerelease release, tag
  `v0.0.17` at commit
  `3131caffc371695b0acac9e61bc23de3910e4128`, published on 2026-05-18.
  The annotated tag and commit are unsigned, and GitHub does not mark the
  release immutable. The bot-uploaded release assets nevertheless carry
  GitHub SHA-256 digests that exactly match the downloaded archives:
  `0d21d9845183e12be640b622ed5adcaa04f77e835cc3671a26a291caf7f2e9c9`
  for amd64 and
  `f675a01a1ce43b2d219bb5dba23fbc3d4016fbc1fd9b217c6851068fe1264354`
  for arm64. Both archives pass their Manifest BLAKE2B, SHA-512, and size
  checks and contain only the expected executable, README, and upstream
  Apache license.
- Replaced the source-plus-private-Go-vendor build with upstream's official
  statically linked amd64 and arm64 binaries. This avoids hosting another
  generated dependency bundle and preserves the existing `gui-apps/hyprmon`
  atom for seamless upgrades. The old 0.0.12 and 0.0.15 ebuilds and Manifest
  objects were removed. Their two obsolete vendor archives were removed from
  every revision of `nekochigura-dependencies`; the retained two-commit
  history is signed and was force-pushed from `43ec2e4` to `94d2ae4` with an
  exact force-with-lease guard. A deep clone therefore no longer downloads
  either HyprMon archive.
- Both official binaries identify version 0.0.17 and the tagged commit, were
  built with Go 1.26.3 from an unmodified checkout, and use portable baselines:
  `GOAMD64=v1` and `GOARM64=v8.0`. They are stripped, static ET_EXEC files
  with non-executable stacks and no dynamic dependencies, RPATH, RUNPATH,
  text relocations, or executable-stack request. The ebuild consequently
  restricts stripping and registers the installed executable in
  `QA_PREBUILT`.
- Auditing the linked module graph found Apache-2.0, BSD, MIT, Unicode-3.0,
  and Unicode-DFS-2016 terms. Upstream's binary archives include only
  HyprMon's Apache license, so the overlay now installs that license plus a
  comprehensive `THIRD-PARTY-NOTICES` document covering the Go runtime, every
  linked module, and both generations of embedded Unicode data. All terms
  permit binary redistribution with these notices; no `bindist` or `mirror`
  restriction is needed.
- The 0.0.17 changes include Hyprland 0.55-or-newer Lua configuration output,
  managed sidecar configuration, and corrected vertical and negative-coordinate
  layouts. Runtime inspection found only the `hyprctl` interface, so the
  existing `gui-wm/hyprland` dependency remains sufficient and no Lua runtime
  dependency is needed. Per maintainer policy, the stable upstream release is
  stable-keyworded for both supplied architectures: `amd64 arm64`.
- Clean native amd64 and arm64-profile Portage staging installs succeeded.
  Each staged binary is byte-identical to its upstream payload, modes are
  0755, documentation is 0644, and the installed compressed third-party notice
  decompresses byte-for-byte to the overlay source. Native amd64 and QEMU
  arm64 invocations both report 0.0.17 and produce complete help output.
  Ebuild syntax, metadata XML, Manifest integrity, and `git diff --check` pass.
- The laptop's installed 0.0.15 passed all three recorded content checks and
  no HyprMon process was running. It was deliberately not upgraded live.
  Targeted pkgcheck reports only the intentional dependency-policy mismatch:
  Hyprland is testing-only on amd64 and has no arm64 keyword, so stable and
  development profiles cannot currently solve the stable HyprMon dependency.
  The authoritative full-tree scan now has 57 redundant versions and seven
  reports in each nonsolvable-dependency class.

### Issue 33 — Hyprsunset 0.4.0 update and dependency corrections

Status: fixed and verified on 2026-07-17 with `hyprsunset-0.4.0` for amd64.

- Updated from 0.3.3 to the latest official non-prerelease release, v0.4.0,
  published on 2026-07-13. The lightweight tag points directly to commit
  `25f704346ec22e7623b0873ef8c4573b57ca1512`; there is no separate tag
  signature, but GitHub verifies the commit's SSH signature as valid. The
  release is not marked immutable and has no uploaded assets. Its generated
  tag archive is 15,401 bytes with SHA-256
  `5980e65ec650010e36c52e5f5acc0df9fd2d20051c63b89305bdc13276f237a6`.
  The archive has a safe single-directory layout and no bundled dependencies;
  its Manifest BLAKE2B and SHA-512 hashes were independently reproduced.
- The release fixes a high-CPU event-loop busy loop; malformed gamma IPC
  handling; reset/profile crashes with no profiles; max-gamma handling without
  profiles; and malformed profile times. It also adds whole-profile and
  per-field resets, current-profile reporting, identity query/set support, and
  corrected trace filtering. The old 0.2.0 and 0.3.3 ebuilds and distfile
  records were removed.
- Fixed missing direct dependency metadata. The executable links Hyprlang and
  uses an API introduced in 0.4.0, so the ebuild now requires
  `>=dev-libs/hyprlang-0.4.0:=` rather than relying on Hyprland to pull it in
  transitively. Upstream's README requires Hyprland 0.45.0 or newer; this is
  now versioned accordingly without an ABI rebuild operator because Hyprland
  is a runtime compositor, not a linked library. Wayland and Hyprutils remain
  direct linked dependencies.
- Upstream requests C++26. The ebuild now follows the Hypr ecosystem's
  compiler policy with GCC 14 or newer or Clang 18 or newer in both BDEPEND
  and the selected-toolchain check; binary merges bypass the compiler check.
  Independent source builds passed with GCC 16.1.1 and Clang 22.1.8, both
  selecting `-std=gnu++26` and providing `std::chrono::zoned_time`.
- Added a release-archive patch. It removes unused Git probes and compile
  definitions that emitted four fatal-not-a-repository diagnostics and falsely
  labelled archive builds dirty. It also validates IPC reads before indexing
  the receive buffer, sends complete replies while handling interruption and
  suppressing SIGPIPE, and fixes the ignored-write-result compiler warning.
  The same patch updates the user service's obsolete `wiki.hyprland.org` URL
  to `wiki.hypr.land`; the ebuild homepage was updated likewise.
- The stable upstream release is stable-keyworded `amd64` per maintainer
  policy. Its now-unnecessary entry was removed from the overlay's supplied
  `package.accept_keywords` template, while its now-direct testing-only
  Hyprlang dependency is explicitly accepted there. The machine-local copy was
  deliberately left unchanged because the live Portage checkout is an
  unrelated dirty, ahead checkout still containing only the old testing
  ebuild; its Hyprsunset entry will become redundant when that checkout is
  synchronized.
- A clean Portage configure/build/install completed with GCC 16.1.1 and no
  compiler warning or install QA notice. The staged image contains a 0755
  stripped PIE executable, a 0644 README, and a 0644 systemd user service at
  the pkg-config-selected `/usr/lib/systemd/user` path. The binary has an NX
  stack, full RELRO/BIND_NOW, no RPATH, RUNPATH, or text relocation, and direct
  `DT_NEEDED` entries only for Wayland client, Hyprutils, Hyprlang, and standard
  compiler/libc runtimes. The service passes structural verification and is
  installed but not enabled.
- Staged `--version` and `--help` commands pass in a clean environment. A
  normal launch using an explicitly nonexistent Wayland socket and disposable
  runtime/home reports the expected compositor connection failure, exits 1,
  and writes no files. Hyprsunset was not installed or running on the laptop,
  so no live package or Hyprland session was touched. Syntax, metadata XML,
  patch application, Manifest integrity, and `git diff --check` pass.
  Targeted pkgcheck reports only the intentional stable-keyword mismatch with
  the testing-only Hypr dependency stack. The authoritative full-tree scan now
  has 56 redundant versions and nine reports in each nonsolvable-dependency
  class.

### Issue 34 — Breeze Plus 6.28.0 update and icon-theme metadata repair

Status: fixed and verified on 2026-07-17 with `breeze-plus-6.28.0`, keyworded
for amd64, arm64, and testing x86.

- Updated from 6.26.0 to the latest official non-prerelease release, 6.28.0,
  published on 2026-06-30. The annotated tag points to commit
  `a7a9dcb6bcb8045966472744f3e8350905b560da`; both the tag and target commit
  are unsigned. The generated tag archive is 593,368 bytes with SHA-256
  `2462371450507e224aa04404666919e16dcebc4ef120b1349f21cef316d21a73`.
  Its single-root archive layout is safe, and its 499 SVG files all pass
  non-networked XML validation. The obsolete 6.2.5-r1, 6.19.0, and 6.26.0
  ebuilds and distfile records were removed.
- Corrected the aggregate license from LGPL-2.1 alone to
  `LGPL-2.1 CC-BY-SA-4.0`: upstream's top-level license is LGPL-2.1, while
  embedded metadata in supplied icons identifies CC-BY-SA-4.0 content.
  Replaced the indirect Plasma Breeze dependency with the packages that own
  the themes named by both indexes: `kde-frameworks/breeze-icons` for Breeze
  and Breeze Dark, and `x11-themes/hicolor-icon-theme` for Hicolor.
- Added a version-scoped upstream metadata patch. Both themes advertised the
  nonexistent `status/32`, `status/48`, and `status/64` directories while
  omitting populated 24px and scaled 24px app, place, and status paths. They
  also contained two sections for nonexistent scaled Preferences paths. The
  patch removes all stale declarations and sections and adds every missing
  declaration and fixed-size/scaled section. Each theme now has exact equality
  between its 45 payload directories, declared directories, and sections.
- Stable keywords are used on amd64 and arm64. x86 remains testing because
  the required Breeze Icons package is testing-only there; marking Breeze
  Plus stable on x86 would create an unsatisfiable stable package. The payload
  itself is architecture-independent SVG, INI, and relative-symlink data.
- A clean Portage prepare/install completed. The staged image exactly retains
  501 regular files and 349 relative symlinks under the two unique theme roots,
  with files normalized to 0644 and directories to 0755. No symlink is broken,
  absolute, or escapes `/usr/share/icons`; all 499 SVG files parse; and
  `gtk-update-icon-cache` successfully builds a cache for each disposable
  staged theme. The unique roots create no filesystem collision with KDE's
  fallback themes, and the light/dark cross-theme symlinks resolve because
  both roots are installed together. Breeze Plus was not installed on the
  laptop, so no live package or theme configuration was touched.
- Ebuild syntax, metadata XML, patch application, Manifest integrity, and
  `git diff --check` pass. Targeted pkgcheck reports only `PotentialStable` on
  x86, intentionally deferred until Breeze Icons is stable there. The fresh
  authoritative full-tree scan has 49 redundant versions and six potential
  stabilization reports; all other report counts are unchanged.

### Issue 35 — Material Symbols variable-font snapshot update

Status: fixed and verified on 2026-07-17 with
`material-symbols-variable-0_p20260717` for testing amd64, arm64, and x86.

- Updated the pinned variable-font snapshot from 2026-05-29 commit `fef175fe`
  to the current path and repository head at resolution,
  `abd7f5c0e179c83f068c770650bd14ebac5d5a09`, dated 2026-07-17. This is an
  automated, unsigned upstream snapshot rather than a tagged release, so all
  three architecture keywords remain testing. Apache-2.0 is confirmed by the
  pinned repository license and upstream README.
- Continued to fetch only the three required TTF files directly from the
  immutable upstream commit; the overlay hosts no derived artifact. The final
  fully percent-encoded raw URLs were independently exercised through an empty
  Portage distdir, and the downloaded sizes and hashes matched the Manifest.
  The old snapshot ebuild and its three distfile records were removed.
- Tightened the custom unpack phase so directory creation and every controlled
  filename copy terminate the build on failure. The bracketed canonical font
  filenames remain unchanged for compatibility with the installed snapshot.
- All three files are valid version 2.960 TrueType/OpenType variable fonts from
  the Google foundry. Each contains 4,381 glyphs and 6,590 Unicode cmap entries,
  56 glyphs and 20 cmap entries more than the installed version 2.944 files.
  Their family and PostScript names are distinct and correct. All retain the
  same four axes: FILL 0–1, GRAD -50–200, optical size 20–48, and weight
  100–700, with seven named weight instances. Required variable/layout tables
  are present, and HarfBuzz shapes representative icon ligatures at nondefault
  axis extrema.
- A clean Portage install produced byte-identical copies of the three fonts at
  mode 0644, plus the expected 0644 `fonts.scale`, `fonts.dir`, and
  `encodings.dir` files under one 0755 package directory. `mkfontscale`,
  `mkfontdir`, Fontconfig parsing, and a cache refresh in a disposable HOME all
  succeeded. The payload is architecture-independent font data with no ELF or
  executable content. The laptop's installed 2026-05-29 snapshot and live font
  caches were deliberately not changed.
- Ebuild syntax, metadata XML, Manifest integrity, `git diff --check`, and
  targeted pkgcheck pass. The fresh authoritative full-tree scan remains at
  49 redundant versions and has no report-count changes from Issue 34.

### Issue 36 — Twemoji 17.0.3 update and conservative Fontconfig policy

Status: fixed and verified on 2026-07-17 with `twemoji-17.0.3` for amd64,
arm64, and x86.

- Updated to the stable jdecked Twemoji 17.0.3 artwork/project release and the
  corresponding stable TTF release from its actual Linux font distributor,
  JoeBlakeB/ttf-twemoji. Both releases use unsigned lightweight tags: the
  project tag points to `b6b55fef1e8636b540a6d016a4729ca8cdf2e60b`, and
  the font tag points to automated build commit
  `26b26f4281aca2415bc76ac76315fd969b597bfe`. Neither GitHub release is marked
  immutable. Package metadata and the homepage now identify both the artwork
  upstream and the binary-font distributor rather than attributing the TTF to
  the artwork repository alone.
- The 3,857,500-byte release asset matches GitHub's published SHA-256 digest,
  `e7c433a9847eeae644a76bd6b915febd97f8e7835e66b538525e08d36de73fc3`,
  and the independently reproduced Manifest hashes. Its public successful
  build workflow checks out jdecked v17.0.3 plus pinned Fedora and Noto build
  inputs. The complete aggregate license remains
  `Apache-2.0 CC-BY-4.0 MIT OFL-1.1`, covering the build work, graphics,
  project source, and font template respectively.
- Upstream 17.0.3 changes parser handling for variation-selector cases but does
  not change the emoji artwork. Accordingly, the 17.0.2 and 17.0.3 TTFs have
  identical bitmap, layout, cmap, metric, and glyph tables: only 14 bytes differ
  for the internal version string, build timestamp, and derived checksums. The
  new file nevertheless correctly reports version 17.0.3.
- Replaced the legacy `75-twemoji.conf`, which forcibly rewrote requests for
  competing emoji and broad symbol fonts, appended Twemoji to every generic
  text stack, and globally removed part of DejaVu's charset. Those invasive
  rules did not reliably guarantee color rendering. The new conservative
  `45-twemoji.conf` maps only the standard generic `emoji` family and genuine
  historical Twemoji family names. Priority 45 is required because Fontconfig
  expands `emoji` at priority 60; keeping the rule at 75 would make it
  ineffective. Full ordered-config tests select Twemoji for those aliases while
  leaving explicit Noto, Apple, Symbola, Segoe, sans, serif, and monospace
  patterns unmodified. As with other `font.eclass` configurations, the file is
  installed in `conf.avail` and remains administrator-enabled via
  `eselect fontconfig`. Because eselect-owned `conf.d` symlinks are not owned
  by the package, an upgrade that finds the old priority-75 symlink emits exact
  instructions to remove that stale link and enable the priority-45 policy; it
  does not silently change administrator-managed enablement.
- The font is a valid architecture-independent CBDT/CBLC color SFNT with 4,057
  glyphs and 1,502 base cmap codepoints. Its exact global checksum, table
  alignment, family/version/license metadata, Fontconfig classification, and
  representative single, flag, keycap, skin-tone, and ZWJ sequence shaping all
  pass. Its lack of general Latin language coverage is expected for an emoji
  symbol font, not corruption.
- A clean Portage install produced the byte-identical 0644 font, the 0644
  conservative configuration, and the expected 0644 X font index files under
  0755 directories. The zero-entry `fonts.scale` and `fonts.dir` files are
  expected for a bitmap color font. Disposable Fontconfig cache generation
  succeeded; no ELF, executable, or live-system content was present. Twemoji
  was not installed on the laptop, so no live font or configuration changed.
- Ebuild syntax, metadata and Fontconfig XML, Manifest integrity,
  `git diff --check`, and targeted pkgcheck pass. Removing the obsolete 15.1.0
  and 17.0.2 ebuilds and distfile records reduces the authoritative full-tree
  scan to 48 redundant versions; all other report counts are unchanged.

### Issue 37 — Aligned Intel IPU6 HAL and bins snapshot

Status: fixed and verified on 2026-07-18 with the matched HAL and bins
`20260629_2` tags, both kept testing-only on amd64.

- Updated both packages from the special `20250923_ov02e` tag to Intel's
  current consolidated `20260629_2` tag. The HAL tag peels to commit
  `9899efa70921906ee6dd23c9f83aff343968f164`. Its complete change from the
  old commit is limited to corrected 1288x800 OV01A1S configuration in two
  files. All three OV02E files remain byte-identical. The bins tags both peel
  to commit `30e87664829782811a765b0ca9eea3a878a7ff29`; their trees and archive
  payloads are identical after removing the tag-derived top directory.
- Kept `~amd64` because these are hardware-specific snapshots. The HAL now
  requires the bins package with the same snapshot date. The bins are limited
  to glibc systems and declare the actual minimum glibc and GCC runtimes found
  in their symbol tables, plus their direct Expat and zlib library needs.
- Corrected all nine upstream pkg-config files from `/usr/lib` to Gentoo's
  selected library directory. Expanded the prebuilt-file declaration to cover
  all 57 shared and six static libraries. Removed an empty package-local copy
  of the Intel license; Gentoo reads the complete 1,849-byte license from the
  overlay's top-level `licenses` directory, and it matches upstream exactly.
- Removed invalid RUNPATH entries from 15 proprietary libraries with
  `patchelf`: 12 contained Intel's dead internal build path ending in an empty
  element, which makes the loader search the current working directory, and
  three contained `/usr/lib` instead of Gentoo's selected library directory.
  This changes the installed binary bytes despite Intel's license allowing
  binary use and redistribution only without modification. The maintainer
  explicitly chose removal because the trailing empty path is unsafe. The
  original archive remains unchanged and the package remains `strip`,
  `mirror`, and `bindist` restricted. A clean bins install now has no RPATH or
  RUNPATH and emits no related Portage security notice.
- Removed unused GStreamer dependencies from the HAL. Removed the broken live
  tuning switch because it needs an unavailable ChromeOS header. Fixed the PG
  Lite pipeline on because Intel's matching bins do not ship the libraries
  needed by the other pipeline. Tightened the remaining flags so plugin and
  adaptor mode are paired, while non-plugin mode allows exactly one IPU
  target. Deleted the dead commented removal phase.
- Added a small build patch that raises the declared CMake floor to 3.10 and
  stops upstream from turning every warning into a fatal error. This fixes the
  build with GCC 16 while retaining `-Wall`. A clean isolated Portage build
  against the staged bins completed all 313 default HAL build steps and
  installed the adaptor, all three plugins, headers, pkg-config metadata, and
  configuration for all targets. HAL files have no RPATH or RUNPATH. The
  current `icamerasrc-20260629_1` also builds and links against this staged
  result with no RPATH or missing library.
- The staged OV02E files match upstream exactly, and all HAL dependencies
  resolve when the staged bins are supplied. The laptop uses `uvcvideo`, has no
  active IPU6 device or module, and had neither package installed, so no live
  package or camera state changed. Ebuild syntax, metadata XML, exact patch
  application with zero fuzz, Manifest integrity, and `git diff --check` pass.
  Targeted pkgcheck reports only the expected glibc-only profile notices. The
  full-tree scan has 49 redundant versions because the preserved pending Gaze
  snapshot shadows its release ebuild; Issue 37 adds one dev-profile
  nonsolvable dependency report and one required-use default report for musl.

### Issue 38 — Gaze official-upstream snapshot and fork cleanup

Status: fixed and verified on 2026-07-18 with
`gaze-0.2.5_p20260718`, testing-only on amd64.

- Replaced both the official 0.2.4 release ebuild and the unfinished fork
  snapshot with one snapshot from official GunduLabs `main`, pinned to commit
  `4aee4cb3d1533ea475ca5542cc2a91c68154e278`. This includes the merged
  configurable enrollment face-size work, its input-limit fix, and later
  upstream fixes. The former `melynx/gaze` feature branch is no longer needed.
- Fast-forwarded the `melynx/gaze` fork's `main` branch to the same official
  upstream commit over SSH. Deleted the merged
  `feat/configurable-enrollment-face-size` branch from the fork. Remote
  verification shows only `main` for those checked refs.
- Kept all 453 Rust dependencies as individual `CRATES`. No Rust vendor archive
  is hosted. Regenerated the Manifest for the official commit archive and exact
  current lock file, including `cfg_aliases-0.2.2` and `tokio-1.53.0`.
- Rebased the three local safety patches. They require affirmative measured eye
  motion for IR-only liveness, stop a Rust panic from crossing the PAM C entry
  point, and log frame-processing failures that upstream otherwise treats as a
  simple no-face result. All patches apply with zero fuzz.
- Kept the Rust 1.96 minimum and `~amd64`. The post-install action now reloads
  systemd and uses `try-restart` only during a real upgrade. It restarts an
  already running `gazed` service but does not start a stopped service on a
  fresh install.
- An isolated Portage run verified all source files, prepared the patches,
  completed the optimized build, ran every selected workspace test, and built
  a 46.6 MiB install image. Test results were 81 passed and two ignored for the
  daemon, 20 passed for the CLI, 62 passed for core, six passed in doc tests,
  and no failures. PAM, PAM core, and GUI test targets also completed. The
  image contains the daemon, CLI, GUI, PAM module, service, D-Bus policy,
  Polkit policy, configuration, desktop metadata, icon, and optional Hyprlock
  PAM file. It has no broken links or RPATH/RUNPATH entries.
- Targeted pkgcheck and `git diff --check` pass. The laptop still runs the
  previously installed `gaze-0.2.4_p20260716`; this work did not install the
  new package or restart the live service.

### Issue 39 — IPU6 driver kernel-support snapshot

Status: fixed, verified, signed, and published on 2026-07-18 in commit
`19aba9291b400094f718ece574fbf131388207b2`.

- Updated the working ebuild from snapshot `20260327` to Intel's latest
  annotated tag, `20260629_2`, which points to commit
  `c09fa9a6e98b951ea4ab9d4100aa85281a659074`. The upstream change adds nine
  kernel patch files with 565 lines. It adds or adjusts IMX471, OV05C10,
  OV08X40, OV8856, Intel DWC PHY, and Dell XPS support. Module source code did
  not change.
- Kept `~amd64`. Removed the shadowed `20251104` and `20251226` snapshots.
  Regenerated the Manifest from the official tag archive.
- Reordered the non-DKMS preparation test so the default `dkms` path does not
  ask the kernel helper for a version before checking the USE flag.
- Fixed the non-DKMS preparation message to use `KV_FULL`. The old local
  variable existed only inside `pkg_setup`, so the later message printed a
  blank kernel version.
- The default `dkms` path verifies, prepares, and stages the complete 2.4 MiB
  source tree. Its staged `dkms.conf` has the correct package version.
- A clean direct build with `USE="-dkms -modules-sign"` compiled and staged all
  11 expected modules for `7.1.3-gentoo-dist`. Every module reports the matching
  kernel version. GCC 16 warned that the kernel was built with GCC 15, but the
  build completed. Signing was disabled only in this temporary check so the
  test would not read the Secure Boot private key. The ebuild's normal signing
  behavior has not changed. No package or module was installed or loaded.
- Validation found and fixed an existing upstream defect in the default DKMS
  module list. It omitted `gc5035`, and `imx471` and `s5k3j1` shared list index
  8, so the latter replaced the former. The approved local patch adds
  `gc5035`, gives the two sensors separate indices, and shifts later indices so
  every kernel branch remains continuous. It also removes the obsolete
  `CLEAN` setting, which current DKMS ignores with a warning.
- DKMS accepted the staged package. Direct checks confirmed continuous module
  arrays for kernels 5.15, 6.6, 6.8, 6.10, and 7.1. Kernel 7.1 selects all 11
  expected modules. A second clean non-DKMS ebuild run applied both patches,
  compiled all 11 modules, and staged them successfully.
- Metadata XML, `git diff --check`, targeted pkgcheck, and the full-tree
  non-network scan pass. The full scan now reports 51 redundant versions and
  otherwise matches the recorded result classes. The live system remains
  unchanged.

### Issue 40 — GPU Screen Recorder release and packaging repair

Status: fixed, verified, and approved for signed publication on 2026-07-19.

- Updated the versioned ebuild from 5.13.6 to the latest official release,
  5.15.1, at commit `3bdc117b311b787b85e2ab6af1b3d63fcef00e49`.
  Regenerated the Manifest from the official snapshot and kept
  `~amd64 ~arm64`. The live ebuild uses the same packaging. Its local patch
  also applies to current upstream HEAD
  `0c0b40ef92453e8976177698dcb5456637ff3600` from 2026-07-18.
- Replaced the incomplete dependency set. Added direct X11, XDamage, D-Bus,
  PipeWire, native Wayland scanner, Vulkan headers and loader, and
  libjpeg-turbo declarations. FFmpeg now requires its `vulkan` flag. Split
  build, linked, and runtime-only packages instead of copying every dependency
  into `BDEPEND`.
- Added a default-enabled `pipewire` flag that controls both portal capture
  and per-application audio. Added a default-off `nvidia-suspend` flag for
  the global NVIDIA modprobe setting. The laptop has only Intel graphics, but
  the installed GURU 5.14.1 package currently owns
  `/usr/lib/modprobe.d/gsr-nvidia.conf`.
- Found that upstream always compiles `kde_night_light.c`, which uses D-Bus,
  but links D-Bus only when a PipeWire feature is enabled. Added a small Meson
  patch that links D-Bus unconditionally. This makes the no-PipeWire build
  valid.
- Replaced upstream's image-time `setcap` script with Gentoo's `fcaps`
  helper. The installed 5.14.1 `gsr-kms-server` has no file capability even
  though `filecaps` is enabled. The new ebuild disables the upstream script
  and asks `fcaps.eclass` to set `cap_sys_admin` during real post-install.
  The capability is therefore not expected in a temporary staged image.
- A normal isolated build completed 52 steps with PipeWire, portal capture,
  per-application audio, and the systemd user service. A minimal isolated build
  completed 48 steps without those features. A third build confirmed that the
  NVIDIA modprobe file appears only with `nvidia-suspend`. All images contain
  the two binaries, plugin header, manual pages, documentation, and helper
  scripts. The normal image also contains the requested systemd user service.
- Both staged binaries report version 5.15.1. The images have no broken links
  or RPATH/RUNPATH entries. Their direct linked libraries match the selected
  feature sets. Upstream emits non-fatal shadowing and unused-code warnings,
  but both GCC 16 builds complete. Targeted pkgcheck, metadata XML, Manifest,
  patch, and whitespace checks pass. The latest full-tree non-network scan
  reports 48 redundant versions and otherwise matches the recorded result
  classes. No package, capability, service, or modprobe setting was changed on
  the live system.

### Issue 41 — video-compare release and license repair

Status: fixed, verified, and approved for signed publication on 2026-07-19.

- Updated the ebuild from 20260502 to the latest official release, 20260708,
  at commit `a134dd707fc9d4cb3a2735471559f930b08ec457`. This release adds a
  configurable UI scale, improves video-duration detection, rejects unlikely
  duration metadata, and adds a decoder option that can rewrite duration data.
  Kept the existing `~amd64` keyword.
- Removed all six older snapshots: 20251213, 20260120, 20260121, 20260214,
  20260308, and 20260502. Regenerated the Manifest from the official 20260708
  archive.
- Corrected `LICENSE` from `GPL-2` to `GPL-2+ MIT OFL-1.1 public-domain`.
  The project permits GPL version 2 or later. Its bundled `argagg.h` uses MIT,
  its embedded Source Code Pro font uses SIL Open Font License 1.1, and its
  bundled stb image writer is public domain.
- Retained the local Gentoo build patch. It applies cleanly to 20260708. It
  keeps Portage's compiler and linker flags, uses the selected compiler,
  avoids stripping during the upstream install step, and uses pkg-config for
  FFmpeg and SDL libraries.
- A clean isolated GCC 16 build and staged install completed. The build used
  `-O2 -pipe -march=x86-64-v3` and the configured linker flags. The staged
  program reports `20260708-santiago`. All direct libraries resolve. The
  installed tree contains only the executable and README. It has no broken
  links or RPATH/RUNPATH entries. Upstream has no non-interactive automated
  test target, so the staged `--help` and `--version` commands served as smoke
  tests.
- Targeted pkgcheck, metadata XML, Manifest, patch, and whitespace checks
  pass. The full-tree non-network scan now reports 43 redundant versions and
  otherwise matches the recorded result classes. The live system remains on
  video-compare 20260502; no package was installed or changed.

### Issue 42 — Clash Party binary update and runtime repair

Status: fixed, verified, and approved for signed publication on 2026-07-19.

- Updated `net-proxy/clash-party-bin` from 1.9.5 to the latest official
  release, 2.0.0, at commit `1caff4cabd83d0e2768ecadf52c85c5dcc0ed9de`.
  This release adds plugins and custom tray icons, improves large-subscription
  performance, and fixes several Linux and general defects. Removed the
  redundant 1.9.2 and 1.9.5 ebuilds. Kept `~amd64`.
- Downloaded the official amd64 Debian package. Its SHA-256 matches upstream's
  published `5355b359bdbdfc0cac9e53f114c953a143a85f72a9af74caa3ffbe885f485e4a`.
  Regenerated the Manifest. Kept `mirror` and `strip` restrictions so the
  large upstream binary stays outside overlay mirrors and Portage does not
  alter prebuilt files. Removed `bindist`: the project uses GPL-3 and upstream
  distributes the same binary with the required Electron and Chromium license
  notices.
- Replaced the incomplete runtime list with the libraries used by Electron
  41.8.0 and by the package's native helper. Added accessibility, GLib, NSPR,
  graphics, audio, printing, D-Bus, X11, udev, UUID, desktop helper, and Polkit
  dependencies. The package uses Polkit's `pkexec` prompt when a user requests
  TUN permission. Ayatana AppIndicator remains an optional tray integration
  and is now reported through an install-time suggestion.
- Replaced manual desktop and icon cache hooks with `xdg.eclass`. Added the
  standard Chromium kernel sandbox check. Restored mode 4755 only on Electron's
  small `chrome-sandbox` helper. Upstream's Debian script also gives all three
  large Mihomo engines the set-user-ID bit. The Gentoo ebuild deliberately does
  not do that automatically. They remain mode 0755, and the application can
  request permission for the selected core only when the user enables TUN.
- A clean isolated unpack and staged install completed. The 572 MiB installed
  tree contains the application, three static Mihomo engines, desktop entry,
  icon, and command link. All dynamic libraries resolve and no links are
  broken. Two Electron files use the intended `$ORIGIN` runtime search path to
  find libraries beside themselves; there is no absolute or writable search
  path. A ten-second launch with a temporary profile started the application
  and bundled core successfully, then the timeout stopped them. No process
  remains and the live profile was untouched.
- Targeted pkgcheck, dependency solving, metadata XML, Manifest, and whitespace
  checks pass. The full-tree non-network scan now reports 42 redundant versions
  and otherwise matches the recorded result classes. The live system remains
  on Clash Party 1.9.5; no package was installed or changed.

### Issue 43 — Ollama source update and packaging repair

Status: fixed, verified, signed, and published on 2026-07-19 in commit
`df935fa6190514d0f5b903841cabb2c731dc6c99`.

- Updated the source-built `sci-ml/ollama` from 0.23.2 to the latest official
  stable release, 0.32.1. Removed all seven older source ebuilds: 0.14.2,
  0.14.3_rc3, 0.15.5, 0.16.1, 0.17.5, 0.18.2, and 0.23.2. Kept stable
  `amd64`. The separate `sci-ml/ollama-bin` package was not changed.
- Added the official 0.32.1 Go dependency archive and the exact llama.cpp
  `b9888` source archive. The build supplies both from `DISTDIR`, so CMake does
  not fetch source from the network. Regenerated the Manifest. Updated the Go
  build dependency to 1.26, which matches upstream's `go.mod` requirement.
- Reworked the ebuild for Ollama's current CMake superbuild. It now builds the
  Go client, the runtime-selected set of CPU runners, and optional CUDA, ROCm,
  and Vulkan runners. It passes the package version explicitly and uses
  `lib64/ollama` on this system. CUDA selects the version 12 or 13 backend from
  the installed toolkit. Dependency solving selected the available CUDA
  12.9.2 toolkit and the CUDA 12 backend.
- Replaced the obsolete GNU install-directory patch with one downstream build
  policy patch. It lets Portage control stripping. It stops the CUDA and ROCm
  builds from copying toolchain libraries and ROCm data into the package. It
  clears Portage's temporary `DESTDIR` during nested installs, which prevents a
  second 324 MiB copy under a fake `/tmp` path. It also gives every copied CPU
  runner the safe `$ORIGIN` runtime search path instead of recording the
  temporary build directory.
- Corrected the license set to `Apache-2.0 BSD BSD-2 ISC MIT` for Ollama and
  its statically linked Go modules and embedded code. Re-enabled upstream's Go
  tests. The normal integration tests need explicit build tags and external
  services, so the ordinary package test does not run them.
- Updated `acct-user/ollama` from revision 3 to 4. CUDA, ROCm, or Vulkan now
  adds the service account to both `render` and `video`, and declares the two
  account-group dependencies. The Ollama ebuild passes matching USE flags to
  the account package.
- Installed the previously unused OpenRC configuration file. Both service
  systems now use `/var/lib/ollama` as the home and working directory. Fixed
  the systemd unit's invalid literal `PATH=$PATH`. Added safe systemd limits,
  an OpenRC network dependency, a private file-creation mask, clear network
  exposure comments, and mode 0750 for `/var/log/ollama`.
- A clean GCC 16 CPU build compiled every runtime-selected CPU runner. The full
  Go test suite passed. A separate clean Vulkan build found the system Vulkan
  loader and shader tools, generated all shaders, and built the Vulkan runner.
  The staged client reports version 0.32.1. All staged runtime paths are
  `$ORIGIN`; none contains a build path. The Vulkan runner links to the system
  `libvulkan.so.1`, and the image contains no copied toolchain libraries or
  fake `/tmp` tree.
- The isolated install checks stopped only when `fowners` looked for the live
  `ollama` account. This laptop does not have that account because the source
  package is not installed. A normal emerge installs `acct-user/ollama-4`
  first. No live account was created and no package or service was changed.
- The full package dependency solver passes for CPU, Vulkan, and CUDA. ROCm
  remains untested and deferred. Ollama needs the upstream-supported ROCm 7.2
  series, while Gentoo still keywords the required HIP, hipBLAS, and rocBLAS
  7.2 packages as unstable. This produces the recorded optional-ROCm
  `NonsolvableDeps` scan findings on stable profiles. Fixing the wider ROCm
  package set remains out of scope.
- Syntax, patch, Manifest, metadata, whitespace, and targeted quality checks
  pass apart from that known ROCm keyword limit. Upstream llama.cpp emits a
  harmless GCC 16 warning about combining two enum types. Its unused MLX path
  also asks for an old CMake compatibility level. Neither warning affects the
  Linux CPU or Vulkan output. The full-tree non-network scan now reports 39
  redundant versions and the result counts recorded below.

### Issue 44 — Ollama official binary update and packaging repair

Status: fixed, verified, signed, and published on 2026-07-19 in commit
`5b2dd037354e1c048aac330dbd4af521c4eff9b3`.

- Updated `sci-ml/ollama-bin` from 0.30.0 to the latest official stable
  release, 0.32.1. Removed all eight older binary ebuilds: 0.14.2,
  0.14.3_rc3, 0.15.5, 0.16.1, 0.17.5, 0.18.2, 0.23.2, and 0.30.0. Kept
  stable `amd64` and the mutual block with the source-built package.
- Fixed the ROCm download layout. Upstream's installer always extracts the
  base Linux archive and then adds the ROCm archive when it detects AMD
  hardware. The old ebuild incorrectly selected the ROCm add-on instead of
  the base archive. The new ebuild always installs the base and conditionally
  overlays ROCm.
- Made the GPU flags control installed files. `cuda` keeps the bundled CUDA
  12 and 13 runners, `vulkan` keeps the Vulkan runner and adds the system
  Vulkan loader, and `rocm` adds the ROCm 7.2 runner archive. Disabled CUDA
  and Vulkan directories are removed. All three flags pass through to
  `acct-user/ollama-4` for the required device-group access.
- Corrected the license expression for the bundled Go code, llama.cpp code,
  GCC OpenMP library, and optional NVIDIA libraries. CUDA now conditionally
  adds `NVIDIA-CUDA` and `RESTRICT=bindist`; direct upstream installation
  remains available. The package remains restricted from Gentoo mirrors and
  from stripping because it installs upstream binaries.
- Fixed upstream runtime search paths in every CPU runner. They contained
  Ollama's private `/build/llama-server-cpu/bin` directory. The ebuild now
  rewrites each path to `$ORIGIN`, meaning the installed library's own
  directory. Added the required `patchelf` build dependency.
- Fixed installed modes. The old `doins` call made `llama-server` and
  `llama-quantize` non-executable. Both helpers and every shared library now
  receive the correct executable mode. Expanded `QA_PREBUILT` to cover the
  client and the entire bundled runner tree.
- Synchronized the systemd unit, OpenRC script, and OpenRC configuration with
  the repaired source package. Both service systems use `/var/lib/ollama` as
  the home and working directory. The invalid literal `PATH=$PATH` is gone.
  The services have the same safe file mask, systemd restrictions, OpenRC
  network dependency, logging configuration, and protected log directory as
  the source package.
- Replaced the placeholder maintainer address with the overlay maintainer's
  real address. Updated the USE flag descriptions to state what each flag
  installs and why it changes the service account.
- GitHub's release API reports 0.32.1 as released on 2026-07-16. The normal
  1,435,963,408-byte archive and ROCm 1,047,646,096-byte archive both matched
  GitHub's published SHA-256 values. Both are recorded in the regenerated
  Manifest. The ROCm archive was inspected only far enough to confirm that it
  is an add-on rooted at `lib/ollama/rocm_v7_2`; ROCm execution remains
  untested and deferred.
- Separate isolated staging passes covered the default CPU image and the
  CUDA plus Vulkan image. The staged client reports version 0.32.1. The CPU
  image excludes CUDA and Vulkan directories. The GPU image contains both
  CUDA generations and Vulkan. Both helper programs are executable, and all
  staged runtime paths are local; none contains an upstream build path.
- The isolated install reached only the final `fowners` call, which cannot
  resolve the absent live `ollama` user on this laptop. A normal merge installs
  `acct-user/ollama-4` first. No account, package, or service was installed or
  changed. Dependency previews pass for CPU, CUDA plus Vulkan, and ROCm.
- Syntax, Manifest, metadata, whitespace, dependency, and targeted package
  checks pass. The full non-network overlay scan now reports 29 redundant
  versions and the counts recorded below.

## Automated pkgcheck summary

Repository-wide non-network scan counts:

| Count | Check |
|---:|---|
| 29 | RedundantVersion |
| 6 | PythonCompatUpdate |
| 5 | NonsolvableDepsInStable |
| 6 | NonsolvableDepsInDev |
| 6 | PotentialStable |
| 2 | DeprecatedEclass |
| 1 | UnknownCategoryDirs |
| 4 | RequiredUseDefaults |
| 1 | BetterCompressionUri |

Most of the originally reported 107 redundant versions are fully shadowed
older point releases.
Prune them per package after the newest replacement builds successfully, unless
there is an intentional rollback/security/channel reason to retain them.

Notable redundant groups include older 1Password, Azure CLI, Passless,
SongRec, Bun, OpenCode,
Fuzzel, wlogout, XDPH, Breeze Plus, Twemoji,
curl-impersonate, RyzenAdj, EVDI, adw-gtk3, Catppuccin Neovim,
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
2. Issues 43 and 44 are signed, published, and cleaned up. Present the next
   package issue as a separate proposal.
3. Continue strictly one issue at a time, including signed publication and
   cleanup before advancing.
