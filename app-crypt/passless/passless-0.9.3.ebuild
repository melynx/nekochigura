# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	aead@0.5.2
	aes-gcm@0.10.3
	aes@0.8.4
	aho-corasick@1.1.4
	android_system_properties@0.1.5
	anstream@0.6.21
	anstream@1.0.0
	anstyle-parse@0.2.7
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.13
	anyhow@1.0.102
	async-broadcast@0.7.2
	async-channel@2.5.0
	async-executor@1.14.0
	async-io@2.6.0
	async-lock@3.4.2
	async-process@2.5.0
	async-recursion@1.1.1
	async-signal@0.2.13
	async-task@4.7.1
	async-trait@0.1.89
	atomic-waker@1.1.2
	atty@0.2.14
	autocfg@1.5.0
	base16ct@0.2.0
	base64@0.21.7
	base64@0.22.1
	base64ct@1.8.3
	bitfield@0.14.0
	bitflags@2.11.0
	block-buffer@0.10.4
	block-padding@0.3.3
	block2@0.6.2
	blocking@1.6.2
	bumpalo@3.20.2
	cbc@0.1.2
	cbor4ii@1.2.2
	cc@1.2.56
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	ciborium-io@0.2.2
	ciborium-ll@0.2.2
	ciborium@0.2.2
	cipher@0.4.4
	clap-serde-derive@0.2.1
	clap-serde-proc@0.2.0
	clap@4.6.0
	clap_builder@4.6.0
	clap_complete@4.6.0
	clap_derive@4.6.0
	clap_lex@1.0.0
	colorchoice@1.0.4
	concurrent-queue@2.5.0
	const-oid@0.9.6
	const_format@0.2.35
	const_format_proc_macros@0.2.34
	core-foundation-sys@0.8.7
	core2@0.4.0
	cpufeatures@0.2.17
	crossbeam-utils@0.8.21
	crunchy@0.2.4
	crypto-bigint@0.5.5
	crypto-common@0.1.7
	ctr@0.9.2
	ctrlc@3.5.2
	curve25519-dalek-derive@0.1.1
	curve25519-dalek@4.1.3
	darling@0.23.0
	darling_core@0.23.0
	darling_macro@0.23.0
	der@0.7.10
	deranged@0.5.8
	digest@0.10.7
	dirs-sys@0.5.0
	dirs@6.0.0
	dispatch2@0.3.1
	displaydoc@0.2.5
	ecdsa@0.16.9
	ed25519-dalek@2.2.0
	ed25519@2.2.3
	elliptic-curve@0.13.8
	endi@1.1.1
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	env_filter@1.0.0
	env_logger@0.11.9
	equivalent@1.0.2
	errno@0.3.14
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	fastrand@2.3.0
	ff@0.13.1
	fiat-crypto@0.2.9
	find-msvc-tools@0.1.9
	form_urlencoded@1.2.2
	futures-core@0.3.32
	futures-io@0.3.32
	futures-lite@2.6.1
	generic-array@0.14.7
	getrandom@0.2.17
	getrandom@0.3.4
	ghash@0.5.1
	git-state@0.1.0
	git2@0.20.4
	group@0.13.0
	half@1.8.3
	half@2.7.1
	hashbrown@0.16.1
	heck@0.5.0
	hermit-abi@0.1.19
	hermit-abi@0.5.2
	hex@0.4.3
	hidapi@2.6.5
	hkdf@0.12.4
	hmac@0.12.1
	hostname-validator@1.1.1
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.1.1
	icu_locale_core@2.1.1
	icu_normalizer@2.1.1
	icu_normalizer_data@2.1.1
	icu_properties@2.1.2
	icu_properties_data@2.1.2
	icu_provider@2.1.1
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.1
	indexmap@2.13.0
	inout@0.1.4
	is_debug@1.1.0
	is_terminal_polyfill@1.70.2
	itoa@1.0.17
	jiff-static@0.2.23
	jiff@0.2.23
	jobserver@0.1.34
	js-sys@0.3.91
	lazy_static@1.5.0
	libc@0.2.183
	libgit2-sys@0.18.3+1.9.2
	libredox@0.1.14
	libz-sys@1.1.25
	linux-raw-sys@0.12.1
	litemap@0.8.1
	lock_api@0.4.14
	log@0.4.29
	mac-notification-sys@0.6.12
	mbox@0.7.1
	memchr@2.8.0
	memoffset@0.9.1
	nix@0.30.1
	nix@0.31.2
	notify-rust@4.12.0
	num-conv@0.2.0
	num-derive@0.4.2
	num-traits@0.2.19
	num_threads@0.1.7
	objc2-core-foundation@0.3.2
	objc2-encode@4.1.0
	objc2-foundation@0.3.2
	objc2@0.6.4
	oid@0.2.1
	once_cell@1.21.3
	once_cell_polyfill@1.70.2
	opaque-debug@0.3.1
	option-ext@0.2.0
	ordered-stream@0.2.0
	p256@0.13.2
	parking@2.2.1
	pem-rfc7468@0.7.0
	percent-encoding@2.3.2
	picky-asn1-der@0.4.1
	picky-asn1-x509@0.12.0
	picky-asn1@0.8.0
	pin-project-lite@0.2.17
	piper@0.2.5
	pkcs8@0.10.2
	pkg-config@0.3.32
	polling@3.11.0
	polyval@0.6.2
	portable-atomic-util@0.2.5
	portable-atomic@1.13.1
	potential_utf@0.1.4
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	primeorder@0.13.6
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	procfs-core@0.18.0
	procfs@0.18.0
	prs-lib@0.5.7
	quick-xml@0.37.5
	quote@1.0.45
	r-efi@5.3.0
	rand@0.8.5
	rand_chacha@0.3.1
	rand_core@0.6.4
	redox_users@0.5.2
	regex-automata@0.4.14
	regex-syntax@0.8.10
	regex@1.12.3
	rfc6979@0.4.0
	rpassword@7.4.0
	rtoolbox@0.0.3
	rustc_version@0.4.1
	rustix@1.1.4
	rustversion@1.0.22
	same-file@1.0.6
	scopeguard@1.2.0
	sec1@0.7.3
	secstr@0.5.1
	semver@1.0.27
	serde@1.0.228
	serde_bytes@0.11.19
	serde_cbor@0.11.2
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.149
	serde_repr@0.1.20
	serde_spanned@1.0.4
	sha2@0.10.9
	shadow-rs@1.7.1
	shellexpand@3.1.2
	shlex@1.3.0
	signal-hook-registry@1.4.8
	signature@2.2.0
	slab@0.4.12
	smallvec@1.15.1
	soft-fido2-crypto@0.12.2
	soft-fido2-ctap@0.12.2
	soft-fido2-transport@0.12.2
	soft-fido2@0.12.2
	spin@0.10.0
	spki@0.7.3
	stable_deref_trait@1.2.1
	strsim@0.11.1
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.117
	synstructure@0.13.2
	target-lexicon@0.12.16
	tauri-winrt-notification@0.7.2
	tempfile@3.27.0
	thiserror-impl@2.0.18
	thiserror@2.0.18
	time-core@0.1.8
	time-macros@0.2.27
	time@0.3.47
	tinystr@0.8.2
	toml@1.0.6+spec-1.1.0
	toml_datetime@1.0.0+spec-1.1.0
	toml_edit@0.25.4+spec-1.1.0
	toml_parser@1.0.9+spec-1.1.0
	toml_writer@1.0.6+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing@0.1.44
	tss-esapi-sys@0.5.0
	tss-esapi@7.6.0
	typenum@1.19.0
	tz-rs@0.7.3
	tzdb@0.7.3
	tzdb_data@0.2.3
	uds_windows@1.2.0
	unicode-ident@1.0.24
	unicode-xid@0.2.6
	universal-hash@0.5.1
	url@2.5.8
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.22.0
	vcpkg@0.2.15
	version-compare@0.2.1
	version_check@0.9.5
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.2+wasi-0.2.9
	wasm-bindgen-macro-support@0.2.114
	wasm-bindgen-macro@0.2.114
	wasm-bindgen-shared@0.2.114
	wasm-bindgen@0.2.114
	which@8.0.2
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.2.0
	windows-core@0.61.2
	windows-core@0.62.2
	windows-future@0.2.1
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.1.3
	windows-link@0.2.1
	windows-numerics@0.2.0
	windows-result@0.3.4
	windows-result@0.4.1
	windows-strings@0.4.2
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-threading@0.1.0
	windows-version@0.1.7
	windows@0.61.3
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@0.7.15
	wit-bindgen@0.51.0
	writeable@0.6.2
	yoke-derive@0.8.1
	yoke@0.8.1
	zbus@5.14.0
	zbus_macros@5.14.0
	zbus_names@4.3.1
	zerocopy-derive@0.8.42
	zerocopy@0.8.42
	zerofrom-derive@0.1.6
	zerofrom@0.1.6
	zeroize@1.8.2
	zeroize_derive@1.4.3
	zerotrie@0.2.3
	zerovec-derive@0.11.2
	zerovec@0.11.5
	zmij@1.0.21
	zvariant@5.10.0
	zvariant_derive@5.10.0
	zvariant_utils@3.3.0
"

inherit cargo systemd udev

DESCRIPTION="Software FIDO2 authenticator that emulates hardware security keys"
HOMEPAGE="https://github.com/pando85/passless"
SRC_URI="
	https://github.com/pando85/passless/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD LGPL-3 MIT
	MPL-2.0 Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+systemd +tpm"

DEPEND="
	dev-libs/libusb:1
	sys-apps/dbus
	tpm? ( app-crypt/tpm2-tss )
"
RDEPEND="
	${DEPEND}
	acct-group/fido
	systemd? ( sys-apps/systemd )
"
BDEPEND="
	virtual/pkgconfig
"

# Minimum Rust version required
RUST_MIN_VER="1.70.0"

QA_FLAGS_IGNORED="usr/bin/passless"

src_unpack() {
	cargo_src_unpack
}

src_prepare() {
	default
}

src_compile() {
	# Build the passless binary from the workspace
	cargo_src_compile --package passless-rs
}

src_install() {
	cargo_src_install --path cmd/passless

	# Install systemd service (user service)
	if use systemd; then
		systemd_douserunit contrib/systemd/passless.service
	fi

	# Install udev rules
	udev_dorules contrib/udev/90-passless.rules

	# Install sysusers configuration
	insinto /usr/lib/sysusers.d
	newins contrib/sysusers.d/passless.conf passless.conf

	# Install modules-load.d configuration for uhid
	insinto /usr/lib/modules-load.d
	newins contrib/modules-load.d/fido.conf fido.conf

	# Documentation
	dodoc README.md CHANGELOG.md DEVELOPMENT.md
}

pkg_postinst() {
	udev_reload

	elog "Passless is a software FIDO2 authenticator that runs as a virtual"
	elog "UHID device on Linux."
	elog ""
	elog "To use passless:"
	elog "  1. Add your user to the fido group:"
	elog "     usermod -aG fido <your-username>"
	elog ""
	elog "  2. The uhid kernel module should be automatically loaded."
	elog "     If not, load it manually:"
	elog "     modprobe uhid"
	elog ""
	elog "  3. Log out and back in for group changes to take effect"
	elog ""

	if use systemd; then
		elog "  4. Enable and start the passless service:"
		elog "     systemctl --user enable --now passless.service"
		elog ""
		elog "For troubleshooting, check:"
		elog "  journalctl --user -u passless.service"
	else
		elog "  4. Without systemd, start passless manually:"
		elog "     passless daemon"
	fi

	elog ""
	elog "Passless supports multiple storage backends:"
	elog "  - pass (default): Uses the pass password manager"
	elog "  - filesystem: Local storage"
	if use tpm; then
		elog "  - tpm: TPM 2.0 (experimental)"
	fi
	elog ""
	elog "Configuration: ~/.config/passless/config.toml"
}

pkg_postrm() {
	udev_reload
}
