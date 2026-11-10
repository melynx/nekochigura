# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	alsa-sys@0.4.0
	alsa@0.11.0
	android_system_properties@0.1.5
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	autocfg@1.5.1
	bitflags@2.13.0
	bumpalo@3.20.3
	cc@1.2.64
	cfg-if@1.0.4
	chrono@0.4.45
	clap-verbosity-flag@3.0.4
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	colorchoice@1.0.5
	colored@3.1.1
	configparser@3.2.0
	core-foundation-sys@0.8.7
	deranged@0.5.8
	equivalent@1.0.2
	errno@0.3.14
	find-msvc-tools@0.1.9
	futures-core@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	hashbrown@0.17.1
	heck@0.5.0
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	indexmap@2.14.0
	is_terminal_polyfill@1.70.2
	js-sys@0.3.102
	libc@0.2.186
	log@0.4.32
	num-conv@0.2.2
	num-traits@0.2.19
	num_threads@0.1.7
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	pin-project-lite@0.2.17
	pkg-config@0.3.33
	powerfmt@0.2.0
	proc-macro2@1.0.106
	quote@1.0.45
	rustversion@1.0.22
	serde_core@1.0.228
	serde_derive@1.0.228
	shlex@2.0.1
	signal-hook-registry@1.4.8
	signal-hook@0.4.4
	simple_logger@5.2.0
	slab@0.4.12
	strsim@0.11.1
	syn@2.0.117
	time-core@0.1.9
	time-macros@0.2.29
	time@0.3.49
	unicode-ident@1.0.24
	utf8parse@0.2.2
	wasm-bindgen-macro-support@0.2.125
	wasm-bindgen-macro@0.2.125
	wasm-bindgen-shared@0.2.125
	wasm-bindgen@0.2.125
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.61.2
"

RUST_MIN_VER="1.88.0"

inherit cargo systemd udev

DESCRIPTION="Speaker protection daemon for Apple Silicon Macs (with Aurora Silicon fixes)"
HOMEPAGE="https://crates.io/crates/speakersafetyd https://github.com/aurora-silicon/speakersafetyd"
SRC_URI="
	https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" MIT MPL-2.0 Unicode-3.0"
# The Aurora profile files are GPL-2.0-only.
LICENSE+=" GPL-2"
SLOT="0"
KEYWORDS="~arm64"

DEPEND="media-libs/alsa-lib"
RDEPEND="
	${DEPEND}
	acct-group/speakersafetyd
	acct-user/speakersafetyd
"
BDEPEND="virtual/pkgconfig"

# Aurora Silicon's speakersafetyd 2.0.1-1.1 patches (alarm-aurora and fedora-aurora).
PATCHES=(
	"${FILESDIR}/${P}-j504-full-speaker-names.patch"
	"${FILESDIR}/${P}-skip-sense-read-after-probe-close.patch"
)

QA_FLAGS_IGNORED="usr/bin/${PN}"

src_install() {
	dobin "$(cargo_target_dir)/${PN}"
	systemd_dounit ${PN}.service
	# A restart within one boot assumes hot speakers (Aurora speakersafetyd-aurora-profiles).
	systemd_install_dropin ${PN}.service "${FILESDIR}/50-aurora-warm-restart.conf"
	udev_dorules 95-speakersafetyd.rules "${FILESDIR}/96-speakersafetyd-aurora.rules"
	insinto /usr/share/${PN}/apple
	doins conf/apple/* "${FILESDIR}/j616.conf"
	dodoc README.md
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
