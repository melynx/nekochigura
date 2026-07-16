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

### Claude Code stable-channel update

`dev-util/claude-code` was updated from 2.1.173 to Anthropic's stable-channel
release 2.1.204. At implementation time, the latest channel was 2.1.211;
stable was deliberately selected because Anthropic describes it as a delayed
channel that skips releases with major regressions.

- Replaced the old unbranded Google Cloud Storage base URL with Anthropic's
  documented `https://downloads.claude.ai/claude-code-releases` endpoint.
- Added the amd64 `cpu_flags_x86_avx` and `cpu_flags_x86_avx2` requirements
  used by the current native x64 binary. Arm64 remains unaffected.
- Removed all twelve older ebuilds and their 48 Manifest entries. The Manifest
  now contains only the four 2.1.204 glibc/musl binaries for amd64 and arm64.
  `RESTRICT="bindist mirror strip"` remains in place, so none of Anthropic's
  proprietary binaries are mirrored or redistributed by the overlay.
- Removed the obsolete, unused `files/managed-settings.json`. The installed
  native managed settings retain `DISABLE_AUTOUPDATER=1`,
  `DISABLE_INSTALLATION_CHECKS=1`, and `installMethod=native`, keeping updates
  under Portage control and preventing a second home-directory installation.
- Downloaded Anthropic's release key, signed manifest, and detached signature
  from the documented official endpoints. The key fingerprint matched
  `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`, the signature was good,
  and every downloaded Linux binary matched its signed SHA-256 checksum.
- All four ELF files matched their declared architecture and libc interpreter.
  A clean staged amd64 glibc install passed; `claude --version` reported
  2.1.204, command-line help ran, all shared libraries resolved, no RPATH or
  RUNPATH was present, and the installed tree contained no broken symlinks.

## Upstream updates found

### Accounts, administration, and crypto

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `app-admin/1password-bin` | 8.12.21, CLI 2.34.0 | 8.12.26, CLI 2.34.1 | Update. https://releases.1password.com/linux/stable/ and https://releases.1password.com/developers/cli/ |
| `app-admin/azure-cli-bin` | 2.87.0 | 2.88.0 | Update. https://github.com/Azure/azure-cli/releases/latest |
| `app-admin/talosctl-bin` | 1.13.3 | 1.13.6 | Update. https://github.com/siderolabs/talos/releases/latest |
| `app-crypt/passless` | 0.11.2 | 0.13.0 | Update. https://github.com/pando85/passless/releases/tag/v0.13.0 |
| `app-admin/ec-su_axb35` | snapshot 20260522 / `b8cab5a` | same HEAD found | Current. https://github.com/cmetz/ec-su_axb35-linux |
| `app-admin/ryzen_smu` | snapshot 20260425 / `0bb95d9` | `1be4fb1`, 2026-06-25 | Optional snapshot update; only test formatting and HX 370 verification documentation changed. https://github.com/amkillam/ryzen_smu/compare/0bb95d961664c7a0ac180f849fa16fe7da71922d...main |
| `app-crypt/picoforge` | 0.5.0 | 0.5.0 stable | Current. `v0.5.0+1` is a prerelease. https://github.com/librekeys/picoforge/releases/latest |

The four `acct-*` packages are local account/group objects with no independent
upstream version stream.

### `app-misc`

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `google-cloud-cli` | 567.0.0 | 576.0.0 | Update. https://docs.cloud.google.com/sdk/docs/release-notes |
| `illogical-impulse-dotfiles` | snapshot 20260529 / `3cb611c` | main `c04b0bb`, 2026-06-14 | Snapshot update. Formal release 2026.05.11 is older than local. https://github.com/end-4/dots-hyprland/commit/c04b0bbc8143a2b2166c1f699f7583cb28ff78fe |
| `moomoo-bin` | 16.18.16308-r1 | 16.22.16708 | Update. https://www.moomoo.com/download/linux |
| `songrec` | 0.7.3 | 0.7.4 | Update. https://github.com/marin-m/SongRec/releases/tag/0.7.4 |
| `brightnessctl` | 0.5.1 | 0.5.1 | Current. https://github.com/Hummer12007/brightnessctl/releases |
| `caelestia-cli` | 1.1.1 | 1.1.1 | Current. https://github.com/caelestia-dots/cli/releases/tag/v1.1.1 |
| `caelestia` | 2.1.0-r2 synthetic meta | Shell 2.1.0 / CLI 1.1.1 | Current as a local meta. |
| `cliphist` | 0.7.0 | 0.7.0 | Current. https://github.com/sentriz/cliphist/releases/tag/v0.7.0 |

The other `illogical-impulse-*` split packages are overlay-local dependency
groupings and have no independent upstream release streams. The Bibata wrapper
is labeled 2.0.6 while the wrapped package and upstream are 2.0.7.

### Development and desktop

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `dev-python/curl-cffi` | 0.14.0 | 0.15.0 | Update. https://pypi.org/project/curl-cffi/0.15.0/ |
| `dev-util/claude-code` | 2.1.204 | stable 2.1.204; latest 2.1.211 | Updated to the verified stable channel. https://downloads.claude.ai/claude-code-releases/stable |
| `dev-util/coder-bin` | 2.32.5 | 2.34.6 | Update. https://github.com/coder/coder/releases/tag/v2.34.6 |
| `dev-util/ghidra-bin` | 12.1 | 12.1.2 | Update. https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.2_build |
| `dev-util/opencode-bin` | 1.17.3 | 1.18.1 | Update. https://github.com/anomalyco/opencode/releases/tag/v1.18.1 |
| `gui-apps/caelestia-shell` | pinned `4a7773c`, actually 2026-06-30 | `aa836f2`, 2026-07-12 | Snapshot update; local PV date 20260706 is inaccurate. https://github.com/caelestia-dots/shell/commit/aa836f2a29bf48b403c57af4bec224aed0412878 |
| `gui-apps/hyprmon` | 0.0.15 | 0.0.17 | Update. https://github.com/erans/hyprmon/releases/tag/v0.0.17 |
| `gui-apps/hyprsunset` | 0.3.3 | 0.4.0 | Update. https://github.com/hyprwm/hyprsunset/releases/tag/v0.4.0 |
| `kde-plasma/breeze-plus` | 6.26.0 | 6.28.0 | Update. https://github.com/mjkim0727/breeze-plus/releases/tag/6.28.0 |

Current at audit time:

- `dev-embedded/rkdeveloptool` snapshot `304f073`
- `dev-lang/bun-bin` 1.3.14
- `dev-python/materialyoucolor` 3.0.2 plus live 9999
- `dev-tex/microtex` pinned `0e3707f` (packaging is broken; see Issue 2)
- `gui-apps/fuzzel` 1.14.1
- `gui-apps/hyprdynamicmonitors` 1.4.0
- `gui-apps/nwg-displays` 0.4.3
- `gui-apps/quickshell` 0.3.0
- `gui-apps/wlogout` 1.2.2-r1
- `gui-apps/wtype` 0.4
- `gui-libs/xdg-desktop-portal-hyprland` 1.3.12

### Media, networking, science, system, and X11

| Package | Newest local | Upstream/current | Status and official source |
|---|---:|---:|---|
| `material-symbols-variable` | snapshot 20260529 / `fef175fe` | `819d786`, 2026-07-10 | Update. https://github.com/google/material-design-icons/commit/819d78680a849ceef4c78f863d8753e3160b7c89 |
| `twemoji` | 17.0.2 | 17.0.3 | Update. https://github.com/jdecked/twemoji/releases/tag/v17.0.3 |
| `ipu6-camera-hal` | `20250923_ov02e` | `20260629_1` track available | Update/revalidate hardware track. https://github.com/intel/ipu6-camera-hal/tags |
| `gst-plugins-icamerasrc` | 20251226 | `20260629_1` | Update. https://github.com/intel/icamerasrc/tags |
| `ipu6-drivers` | 20260327 | `20260629_1` | Update. https://github.com/intel/ipu6-drivers/tags |
| `gpu-screen-recorder` | 5.13.6 plus live 9999 | 5.15.0 | Update versioned ebuild. https://git.dec05eba.com/gpu-screen-recorder/refs/ |
| `makemkv` | 1.18.3 | 1.18.4 | Update. https://www.makemkv.com/download/ |
| `video-compare` | 20260502 | 20260708 | Update. https://github.com/pixop/video-compare/tags |
| `wechat-bin` | 4.1.1 label | current artifact 4.1.1.8 | Update and make URL immutable. https://linux.weixin.qq.com/ |
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
- Bibata 2.0.7
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

- Keywords x86 but line 71 hardcodes `lib64/qt6/qml`.
- Use `get_libdir`/multilib-safe installation paths.
- Package has no `metadata.xml`; 23 local USE flags are undocumented and no
  upstream remote ID is present.
- The file has a pre-existing user modification setting distributor branding
  to `nekochigura`; preserve it while fixing packaging. See the durable policy
  note under "Pre-existing user changes" above.

### Issue 10 — Missing custom Intel camera-bins license

Affected: `media-libs/ipu6-camera-bins-1.0.1_p20250923.ebuild:11`.

- Declares `LICENSE="intel-ipu6-camera-bins"`.
- The overlay `licenses/` directory currently contains only `DisplayLink`.
- pkgcheck reports UnknownLicense.
- Add the exact vendor license text under `licenses/` only after validating its
  redistribution terms and declared identifier.

### Issue 11 — Illogical Impulse keywords and wrong jq dependency

Affected: multiple `app-misc/illogical-impulse-*` metapackages.

- Many packages advertise arm64 and/or x86 even though their dependencies are
  unsatisfiable on those profiles.
- `illogical-impulse-hyprland` even uses stable `amd64 arm64 x86`, while recent
  Hyprland/hyprsunset dependencies are not stable/available for that matrix.
- The master meta transitively advertises combinations that cannot install.
- Likely safe initial policy is `~amd64` only until each architecture is tested.
- `illogical-impulse-basic-1.0-r2.ebuild:23` depends on `dev-python/jq`, but
  upstream scripts invoke the `jq` executable. Use `app-misc/jq`.
- Several metas use GPL-2 despite installing no payload; use
  `LICENSE="metapackage"` consistently.
- Empty homepage/dependency assignments and `RESTRICT=strip` are unnecessary.

### Issue 12 — Invalid category-root app-misc files

- `app-misc/metadata.xml` is cliphist `pkgmetadata`, not category
  `catmetadata`.
- `app-misc/Manifest` is a misplaced duplicate of the cliphist Manifest.
- Remove the root Manifest and replace/delete category metadata as appropriate.

### Issue 13 — 1Password channel/version/install design

Affected: all `app-admin/1password-bin` ebuilds.

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

### Issue 14 — Caelestia snapshot and runtime dependencies

Affected user-modified files; preserve local branding/patch changes.

`gui-apps/caelestia-shell`:

- PV says snapshot 20260706, but pinned commit was made 2026-06-30.
- Current main is 2026-07-12.
- Pinned upstream README says Quickshell must be the Git version, while the
  ebuild accepts tagged `>=0.3.0`.
- QML invokes `hyprctl` and `xmllint`, but dependencies on Hyprland and
  libxml2 are absent.

`app-misc/caelestia-cli`:

- `caelestia install/update` executes Git operations, but unconditional
  `dev-vcs/git` runtime dependency is absent.
- Upstream ships a fish completion that is not installed.
- Preserve the existing non-Arch version patch.

### Issue 15 — cliphist uses an undocumented third-party vendored fork

Affected: `app-misc/cliphist/cliphist-0.7.0.ebuild:10`.

- Homepage/metadata identify official `sentriz/cliphist`.
- Source archive comes from `henri-gasc/cliphist`.
- Comparison found the fork differs mainly by a checked-in `vendor/` tree,
  explaining the 13 MiB vs roughly 356 KiB source size.
- Document this provenance/trust exception or replace it with a dependency
  archive generated and hosted using this overlay's dependency-repository
  convention.

### Issue 16 — keyworded git-r3 dotfile snapshots

Affected: all `app-misc/illogical-impulse-dotfiles` ebuilds.

- Pinned commits are reproducible, but the keyworded packages inherit
  `git-r3`, remain unmirrorable VCS packages, and trigger VisibleVcsPkg.
- Switch to pinned GitHub commit tarballs plus Manifested submodule/source
  archives, or clear KEYWORDS.
- FILESDIR contains multiple identical version-specific patch copies; use
  stable patch names where content is identical.
- Update snapshot to current main only after packaging method is fixed.

### Issue 17 — curl-cffi license and test dependencies

Affected: `dev-python/curl-cffi` 0.13.0 and 0.14.0.

- Declares BSD-2, but upstream 0.14.0 LICENSE/pyproject are MIT.
- Enables the full pytest suite without declaring test-only dependencies such
  as proxy.py, trustme, uvicorn, websockets, cryptography, FastAPI, httpx, and
  charset-normalizer; test collection is expected to fail unless dependencies
  happen to be installed.
- Update to 0.15.0 after correcting license and test dependency policy.
- Python 3.15 pkgcheck suggestion is not proof of upstream support; 0.14
  officially declared only 3.10–3.14. Test before adding 3.15.

### Issue 18 — wtype build-system dependency and reproducibility

Affected: `gui-apps/wtype/wtype-0.4.ebuild`.

- Declares CMake in BDEPEND although upstream uses Meson.
- Missing `dev-util/wayland-scanner` required by protocol generation.
- Upstream build conditionally reads Git and embeds `__DATE__`, making output
  dependent on host state/time. Patch or provide deterministic version/date.

### Issue 19 — hyprdynamicmonitors embeds wall-clock build time

Affected: `gui-apps/hyprdynamicmonitors-1.4.0.ebuild:35`.

- `date -u` is inserted into linker flags, defeating reproducible builds.
- Use a deterministic release timestamp or omit the field.
- Header says distributed under MIT rather than the standard overlay/Gentoo
  GPL-2 ebuild boilerplate.

### Issue 20 — materialyoucolor invalid RESTRICT

Affected: both `dev-python/materialyoucolor` ebuilds.

- `RESTRICT="network-sandbox"` is invalid and flagged UnknownRestrict.
- Evaluate Python 3.15 only after upstream support/testing; pkgcheck's compat
  suggestion is not sufficient evidence.

### Issue 21 — hipSPARSELt deprecated eclass

Affected: 7.1.0 and 7.2.0.

- Inherits deprecated `llvm-r1`; migrate to `llvm-r2` with testing.
- Update source to ROCm 7.2.4.

### Issue 22 — unconditional kernel-module autoloading

Affected:

- `app-admin/ec-su_axb35`
- `app-admin/ryzen_smu`

Both install unconditional `/usr/lib/modules-load.d` entries for niche
hardware modules. Consider optional autoload or installation without forced
loading. Neither ebuild declares useful kernel `CONFIG_CHECK`/minimum-kernel
guards. `ryzen_smu` also keywords `~x86`, despite practical support being
x86-64 Ryzen systems.

### Issue 23 — Azure CLI bundled license declaration

Affected: all `app-admin/azure-cli-bin` ebuilds.

- Binary Debian package is a self-contained `/opt/az` bundle.
- `LICENSE="MIT"` likely under-declares bundled CPython/transitive library
  licenses.
- Audit Debian copyright/SBOM and expand LICENSE before or with the version
  bump.

### Issue 24 — Bibata old Manifest mismatch and stale wrapper

- `x11-misc/bibata-modern-classic-2.0.6-r1` expects one distfile name while
  Manifest contains a revision-suffixed, unknown distfile. pkgcheck reports
  both MissingManifest and UnknownManifest. The version is also fully shadowed.
- `illogical-impulse-bibata-modern-classic-bin-2.0.6-r1` is labeled 2.0.6 while
  its unversioned dependency resolves to Bibata 2.0.7. Bump/decouple the wrapper
  version and add an upstream homepage/version constraint if intended.

### Issue 25 — miscellaneous metadata and policy cleanup

- Missing `metadata.xml` entirely for:
  - `dev-python/curl-cffi`
  - `dev-tex/microtex`
  - `gui-apps/quickshell`
  - `kde-plasma/breeze-plus`
- Many packages lack inferred remote IDs; see pkgcheck summary below.
- `media-libs/ipu6-camera-hal` has seven undocumented local USE flags.
- `media-video/v4l2-relayd` has undocumented `ipu6` USE.
- `net-misc/curl-impersonate` has undocumented `clients` USE.
- `app-admin/talosctl-bin` description says “is an tool”.
- Several ebuilds have empty global assignments, variable ordering, trailing
  blank lines, long lines, or description punctuation warnings. Address these
  opportunistically after functional issues.

## Automated pkgcheck summary

Repository-wide non-network scan counts:

| Count | Check |
|---:|---|
| 107 | RedundantVersion |
| 44 | EmptyGlobalAssignment |
| 43 | VariableOrderWrong |
| 38 | NonsolvableDepsInStable |
| 36 | NonsolvableDepsInDev |
| 23 | ExcessiveLineLength |
| 21 | BadHomepage |
| 20 | MissingRemoteId |
| 17 | UnknownUseFlags |
| 16 | DeprecatedInsinto |
| 12 | TrailingEmptyLine |
| 10 | NonexistentDeps |
| 10 | BadDescription |
| 9 | UnknownRestrict |
| 8 | PythonCompatUpdate |
| 7 | DuplicateFiles |
| 6 | UnusedInherits |
| 5 | WhitespaceFound |
| 4 | MissingPackageRevision |
| 4 | DeprecatedDep |
| 3 | VisibleVcsPkg |
| 3 | PotentialStable |
| 3 | MatchingChksums |
| 2 | RedundantLongDescription |
| 2 | EPyTestPluginsSuggestion |
| 2 | DeprecatedEclass |
| 1 each | UnquotedVariable, UnknownManifest, UnknownLicense, UnknownCategoryDirs, NonConsistentTarUsage, MissingManifest, BetterCompressionUri |

Most of the 107 redundant versions are fully shadowed older point releases.
Prune them per package after the newest replacement builds successfully, unless
there is an intentional rollback/security/channel reason to retain them.

Notable redundant groups include older 1Password, Azure CLI, Talosctl,
Passless, Google Cloud CLI, SongRec, Bun, Coder, Ghidra, OpenCode,
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

1. Commit and push the completed Passless fix, clean its temporary build data,
   and confirm that only unrelated user work remains dirty.
2. Present the Issue 4 (WeChat) proposal and wait for permission.
3. Continue strictly one issue at a time.
