# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	addr2line@0.25.1
	adler2@2.0.1
	aho-corasick@0.6.10
	ansi_term@0.12.1
	ascii@0.7.1
	atty@0.2.14
	autocfg@1.5.0
	backtrace@0.3.76
	bitflags@1.3.2
	bitflags@2.10.0
	block2@0.6.2
	byteorder@1.5.0
	cast@0.2.7
	cc@1.2.49
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chardet@0.2.4
	clap@2.34.0
	combine@2.5.2
	crossbeam-channel@0.5.15
	crossbeam-utils@0.8.21
	ctrlc@3.5.1
	dispatch2@0.3.0
	either@1.15.0
	encoding_rs@0.8.35
	enum_primitive@0.1.1
	error-chain@0.10.0
	failure@0.1.8
	failure_derive@0.1.8
	find-msvc-tools@0.1.5
	getrandom@0.1.16
	gimli@0.32.3
	hermit-abi@0.1.19
	hermit-abi@0.5.2
	image@0.13.0
	itertools@0.8.2
	itoa@1.0.15
	lazy_static@0.2.11
	lazy_static@1.5.0
	libc@0.2.178
	log@0.3.9
	log@0.4.29
	memchr@2.7.6
	miniz_oxide@0.8.9
	nix@0.30.1
	nom@2.1.0
	num-integer@0.1.46
	num-iter@0.1.45
	num-rational@0.1.43
	num-traits@0.1.43
	num-traits@0.2.19
	num_cpus@1.17.0
	objc2-encode@4.1.0
	objc2@0.6.3
	object@0.37.3
	paste@1.0.15
	pbr@1.1.1
	ppv-lite86@0.2.21
	proc-macro2@1.0.103
	quote@1.0.42
	rand@0.7.3
	rand_chacha@0.2.2
	rand_core@0.5.1
	rand_hc@0.2.0
	regex-syntax@0.5.6
	regex@0.2.11
	rmp-serde@0.14.4
	rmp@0.8.14
	rustc-demangle@0.1.26
	rustc_version@0.4.1
	ryu@1.0.20
	safemem@0.2.0
	semver@1.0.27
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.145
	shlex@1.3.0
	strsim@0.8.0
	subparse@0.7.0
	syn@1.0.109
	syn@2.0.111
	synstructure@0.12.6
	textwrap@0.11.0
	thread_local@0.3.6
	threadpool@1.8.1
	ucd-util@0.1.10
	unicode-ident@1.0.22
	unicode-width@0.1.14
	unicode-xid@0.2.6
	utf8-ranges@1.0.5
	vec_map@0.8.2
	vobsub@0.2.3
	wasi@0.9.0+wasi-snapshot-preview1
	webrtc-vad@0.4.0
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-link@0.2.1
	windows-sys@0.61.2
	zerocopy-derive@0.8.31
	zerocopy@0.8.31
"

inherit cargo

DESCRIPTION="Automatic Language-Agnostic Subtitle Synchronization (Command Line Tool)"
HOMEPAGE="https://github.com/kaegi/alass"
SRC_URI="
    https://github.com/melynx/alass/archive/refs/tags/v${PVR}.tar.gz -> ${PVR}.tar.gz
    ${CARGO_CRATE_URIS}
"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
    BSD CC0-1.0 LGPL-3 MIT MPL-2.0 Unicode-3.0
    || ( Apache-2.0 Boost-1.0 )
"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="media-video/ffmpeg"
RDEPEND="${DEPEND}"

S="${WORKDIR}/alass-${PVR}/${PN}"

src_unpack() {
    default || die "src_unpack failed"
	cargo_src_unpack || die "cargo_src_unpack failed"
}

src_configure() {
	default || die "src_configure failed"
}

src_install() {
    cargo_src_install
	dosym alass-cli /usr/bin/alass
}
