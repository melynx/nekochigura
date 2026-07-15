# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	aead@0.6.1
	aes-gcm@0.11.0
	aes@0.9.1
	aho-corasick@1.1.4
	allocator-api2@0.2.21
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.103
	approx@0.5.1
	async-broadcast@0.7.2
	async-channel@2.5.0
	async-executor@1.14.0
	async-io@2.6.0
	async-lock@3.4.2
	async-process@2.5.0
	async-recursion@1.1.1
	async-signal@0.2.14
	async-task@4.7.1
	async-trait@0.1.89
	atomic-waker@1.1.2
	atomic@0.6.1
	atomic_refcell@0.1.14
	autocfg@1.5.1
	base64@0.22.1
	base64ct@1.8.3
	bit-set@0.5.3
	bit-vec@0.6.3
	bitfield-macros@0.19.4
	bitfield@0.19.4
	bitflags@1.3.2
	bitflags@2.13.0
	block-buffer@0.10.4
	block-buffer@0.12.1
	blocking@1.6.2
	bumpalo@3.20.3
	by_address@1.2.1
	bytemuck@1.25.1
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.12.1
	bzip2@0.6.1
	cairo-rs@0.22.0
	cairo-sys-rs@0.22.0
	castaway@0.2.4
	cc@1.2.67
	cfg-expr@0.20.8
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	cipher@0.5.2
	clang-sys@1.8.1
	clang@2.0.0
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	cmov@0.5.4
	colorchoice@1.0.5
	compact_str@0.9.1
	concurrent-queue@2.5.0
	console@0.16.4
	const-oid@0.10.2
	constant_time_eq@0.4.2
	convert_case@0.10.0
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	cpubits@0.1.1
	cpufeatures@0.2.17
	cpufeatures@0.3.0
	crc32fast@1.5.0
	critical-section@1.2.0
	crossbeam-deque@0.8.7
	crossbeam-epoch@0.9.20
	crossbeam-utils@0.8.22
	crossterm@0.29.0
	crossterm_winapi@0.9.1
	crypto-common@0.1.7
	crypto-common@0.2.2
	csscolorparser@0.6.2
	ctr@0.10.1
	ctutils@0.4.2
	darling@0.23.0
	darling_core@0.23.0
	darling_macro@0.23.0
	deflate64@0.1.12
	deltae@0.3.2
	der@0.8.1
	deranged@0.5.8
	derive_more-impl@2.1.1
	derive_more@2.1.1
	dialoguer@0.12.0
	digest@0.10.7
	digest@0.11.3
	document-features@0.2.12
	dunce@1.0.5
	either@1.16.0
	encode_unicode@1.0.0
	endi@1.1.1
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	equivalent@1.0.2
	errno@0.3.14
	euclid@0.22.14
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	fancy-regex@0.11.0
	fast-srgb8@1.0.0
	fastrand@2.4.1
	field-offset@0.3.6
	filedescriptor@0.8.3
	find-msvc-tools@0.1.9
	finl_unicode@1.4.0
	fixedbitset@0.4.2
	flate2@1.1.9
	fnv@1.0.7
	foldhash@0.2.0
	foreign-types-shared@0.1.1
	foreign-types@0.3.2
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.32
	futures-lite@2.6.1
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	futures@0.3.32
	gdk-pixbuf-sys@0.22.0
	gdk-pixbuf@0.22.0
	gdk4-sys@0.11.4
	gdk4@0.11.4
	generic-array@0.14.7
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	ghash@0.6.0
	gio-sys@0.22.8
	gio@0.22.8
	glam@0.30.10
	glam@0.31.1
	glam@0.32.1
	glam@0.33.2
	glib-macros@0.22.6
	glib-sys@0.22.8
	glib@0.22.8
	glob@0.3.3
	gobject-sys@0.22.6
	graphene-rs@0.22.8
	graphene-sys@0.22.8
	gsk4-sys@0.11.4
	gsk4@0.11.4
	gstreamer-app-sys@0.25.0
	gstreamer-app@0.25.2
	gstreamer-base-sys@0.25.3
	gstreamer-base@0.25.3
	gstreamer-sys@0.25.2
	gstreamer-video-sys@0.25.3
	gstreamer-video@0.25.3
	gstreamer@0.25.3
	gtk4-macros@0.11.4
	gtk4-sys@0.11.4
	gtk4@0.11.4
	hashbrown@0.16.1
	hashbrown@0.17.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	hmac-sha256@1.1.14
	hmac@0.13.0
	hostname-validator@1.1.1
	http@1.4.2
	httparse@1.10.1
	hybrid-array@0.4.13
	ident_case@1.0.1
	image@0.25.10
	indexmap@2.14.0
	indoc@2.0.7
	inout@0.2.2
	instability@0.3.12
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itertools@0.15.0
	itoa@1.0.18
	jobserver@0.1.35
	js-sys@0.3.103
	kasuari@0.4.12
	kstring@2.0.3
	lab@0.11.0
	lazy_static@1.5.0
	libadwaita-sys@0.9.2
	libadwaita@0.9.2
	libbz2-rs-sys@0.2.5
	libc@0.2.186
	libm@0.2.16
	line-clipping@0.3.7
	linux-raw-sys@0.12.1
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.33
	lru@0.18.1
	lzma-rust2@0.15.8
	lzma-rust2@0.16.5
	mac_address@1.1.8
	matchers@0.2.0
	matrixmultiply@0.3.10
	mbox@0.7.1
	memchr@2.8.3
	memmem@0.1.1
	memoffset@0.9.1
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	mio@1.2.2
	moxcms@0.8.1
	muldiv@1.0.1
	nalgebra-macros@0.3.0
	nalgebra@0.35.0
	native-tls@0.2.18
	ndarray@0.17.2
	nix@0.29.0
	nom@7.1.3
	nu-ansi-term@0.50.3
	num-bigint@0.4.8
	num-complex@0.4.6
	num-conv@0.2.2
	num-derive@0.4.2
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	num_threads@0.1.7
	oid@0.2.1
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	opencv-binding-generator@0.102.0
	opencv@0.99.0
	openssl-macros@0.1.1
	openssl-probe@0.2.1
	openssl-sys@0.9.117
	openssl@0.10.81
	option-operations@0.6.1
	ordered-float@4.6.0
	ordered-stream@0.2.0
	ort-sys@2.0.0-rc.12
	ort@2.0.0-rc.12
	palette@0.7.6
	palette_derive@0.7.6
	pango-sys@0.22.0
	pango@0.22.8
	parking@2.2.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	pastey@0.2.3
	pbkdf2@0.13.0
	pem-rfc7468@1.0.0
	percent-encoding@2.3.2
	pest@2.8.7
	pest_derive@2.8.7
	pest_generator@2.8.7
	pest_meta@2.8.7
	phf@0.11.3
	phf_codegen@0.11.3
	phf_generator@0.11.3
	phf_macros@0.11.3
	phf_shared@0.11.3
	picky-asn1-der@0.5.6
	picky-asn1-x509@0.15.4
	picky-asn1@0.10.1
	pin-project-lite@0.2.17
	piper@0.2.5
	pkg-config@0.3.33
	polling@3.11.0
	polyval@0.7.2
	portable-atomic-util@0.2.7
	portable-atomic@1.13.1
	powerfmt@0.2.0
	ppmd-rust@1.4.0
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	pxfm@0.1.30
	quote@1.0.46
	r-efi@5.3.0
	r-efi@6.0.0
	rand@0.8.7
	rand_core@0.10.1
	rand_core@0.6.4
	ratatui-core@0.1.2
	ratatui-crossterm@0.1.2
	ratatui-macros@0.7.2
	ratatui-termina@0.1.0
	ratatui-termwiz@0.1.2
	ratatui-widgets@0.3.2
	ratatui@0.30.2
	rawpointer@0.2.1
	rayon-core@1.13.0
	rayon@1.12.0
	redox_syscall@0.5.18
	regex-automata@0.4.15
	regex-syntax@0.8.11
	regex@1.13.0
	ring@0.17.14
	rustc_version@0.4.1
	rustix@1.1.4
	rustls-pki-types@1.15.0
	rustls-webpki@0.103.13
	rustls@0.23.42
	rustversion@1.0.23
	ryu@1.0.23
	safe_arch@1.0.0
	schannel@0.1.29
	scopeguard@1.2.0
	security-framework-sys@2.17.0
	security-framework@3.7.0
	semver@1.0.28
	serde@1.0.228
	serde_bytes@0.11.19
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_plain@1.0.2
	serde_repr@0.1.20
	serde_spanned@1.1.1
	sha1@0.11.0
	sha2@0.10.9
	sha2@0.11.0
	sharded-slab@0.1.7
	shell-words@1.1.1
	shlex@2.0.1
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.8
	signal-hook@0.3.18
	simba@0.10.0
	simd-adler32@0.3.10
	siphasher@1.0.3
	slab@0.4.12
	smallvec@1.15.2
	socket2@0.6.5
	socks@0.3.4
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strsim@0.11.1
	strum@0.28.0
	strum_macros@0.28.0
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.118
	system-deps@7.0.8
	target-lexicon@0.12.16
	target-lexicon@0.13.5
	tempfile@3.27.0
	termina@0.3.3
	terminfo@0.9.0
	termios@0.3.3
	termwiz@0.23.3
	thiserror-impl@1.0.69
	thiserror-impl@2.0.18
	thiserror@1.0.69
	thiserror@2.0.18
	thread_local@1.1.10
	time-core@0.1.9
	time@0.3.53
	tokio-macros@2.7.0
	tokio@1.52.3
	toml@1.1.3+spec-1.1.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.13+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	toml_writer@1.1.2+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	tss-esapi-sys@0.6.0
	tss-esapi@7.7.0
	typed-path@0.12.3
	typenum@1.20.1
	ucd-trie@0.1.7
	uds_windows@1.2.1
	unicode-ident@1.0.24
	unicode-segmentation@1.13.3
	unicode-truncate@2.0.1
	unicode-width@0.2.2
	universal-hash@0.6.1
	untrusted@0.9.0
	ureq-proto@0.6.0
	ureq@3.3.0
	utf8-zero@0.8.1
	utf8parse@0.2.2
	uuid@1.23.5
	valuable@0.1.1
	vcpkg@0.2.15
	version-compare@0.2.1
	version_check@0.9.5
	vtparse@0.6.2
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-macro-support@0.2.126
	wasm-bindgen-macro@0.2.126
	wasm-bindgen-shared@0.2.126
	wasm-bindgen@0.2.126
	webpki-root-certs@1.0.8
	webpki-roots@1.0.8
	wezterm-bidi@0.2.3
	wezterm-blob-leases@0.1.1
	wezterm-color-types@0.3.0
	wezterm-dynamic-derive@0.1.1
	wezterm-dynamic@0.2.1
	wezterm-input-types@0.1.0
	wide@1.5.0
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.3.2
	windows-core@0.62.2
	windows-future@0.3.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-numerics@0.3.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-threading@0.2.1
	windows@0.62.2
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@1.0.4
	wit-bindgen@0.57.1
	zbus@5.17.0
	zbus_macros@5.17.0
	zbus_names@4.3.3
	zbus_polkit@5.0.0
	zeroize@1.9.0
	zeroize_derive@1.5.0
	zip@8.6.0
	zlib-rs@0.6.6
	zopfli@0.8.3
	zstd-safe@7.2.4
	zstd-sys@2.0.16+zstd.1.5.7
	zstd@0.13.3
	zvariant@5.13.0
	zvariant_derive@5.13.0
	zvariant_utils@3.5.0
"

inherit cargo desktop pam systemd xdg

DESCRIPTION="On-device facial authentication daemon, clients, GUI, and PAM module"
HOMEPAGE="https://gaze.gundulabs.com https://github.com/GunduLabs/gaze"
SRC_URI="
	https://github.com/GunduLabs/gaze/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CDLA-Permissive-2.0
	ISC MIT Unicode-3.0 Unicode-DFS-2016 WTFPL-2 ZLIB BZIP2
	|| ( CC0-1.0 MIT-0 )
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+gui +hyprlock test"
RESTRICT="!test? ( test )"

RDEPEND="
	app-crypt/tpm2-tss:=
	dev-libs/openssl:=
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/opencv:=
	media-plugins/gst-plugins-v4l2
	media-video/pipewire[gstreamer,v4l]
	sci-libs/onnxruntime:=
	sys-apps/dbus
	sys-auth/polkit
	sys-libs/pam
	gui? (
		gui-libs/gtk:4
		gui-libs/libadwaita:=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	llvm-core/clang
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-0.2.4-require-ir-motion-evidence.patch"
	"${FILESDIR}/${PN}-0.2.4-contain-pam-panics.patch"
	"${FILESDIR}/${PN}-0.2.4-report-frame-processing-errors.patch"
)

_gaze_ort_env() {
	export ORT_STRATEGY=system
	export ORT_LIB_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
	export ORT_PREFER_DYNAMIC_LINK=1
}

src_compile() {
	_gaze_ort_env

	local -a cargo_args=(
		--package gaze
		--package gaze-cli
		--package pam-gaze
	)
	use gui && cargo_args+=( --package gaze-gui )
	cargo_src_compile "${cargo_args[@]}"
}

src_test() {
	_gaze_ort_env

	local -a packages=(
		gaze
		gaze-cli
		gaze-core
		pam-gaze
		pam-gaze-core
	)
	use gui && packages+=( gaze-gui )

	# Run each workspace member separately.  cargo.eclass' test-harness
	# argument handling can misplace the separator when several repeated
	# --package options are supplied, causing later options to reach a binary's
	# libtest harness instead of Cargo.
	local package
	for package in "${packages[@]}"; do
		cargo_src_test --package "${package}"
	done
}

src_install() {
	dobin target/release/gazed target/release/gaze
	use gui && dobin target/release/gaze-gui

	newpammod target/release/libpam_gaze.so pam_gaze.so

	insinto /etc/gaze
	doins packaging/config/config.toml

	insinto /etc/dbus-1/system.d
	doins packaging/config/com.gundulabs.Gaze.conf

	insinto /usr/share/polkit-1/actions
	doins packaging/config/com.gundulabs.gaze.policy

	systemd_dounit packaging/config/gazed.service

	if use gui; then
		domenu packaging/gui/com.gundulabs.Gaze.desktop
		newicon -s scalable packaging/gui/com.gundulabs.Gaze.svg com.gundulabs.Gaze.svg
		insinto /usr/share/metainfo
		doins packaging/gui/com.gundulabs.Gaze.metainfo.xml
	fi

	use hyprlock && newpamd packaging/pam/hyprlock-gaze hyprlock-gaze

	dodoc README.md
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Gaze is installed but has not been enabled or added to a global PAM stack."
	elog "Review /etc/gaze/config.toml, then start gazed manually for evaluation."
	elog "The first start downloads hash-pinned recognition and liveness models."
	use hyprlock && elog "The opt-in Hyprlock PAM service is /etc/pam.d/hyprlock-gaze."
}

pkg_postrm() {
	xdg_pkg_postrm
}
