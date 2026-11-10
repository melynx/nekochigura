# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	biquad@0.4.2
	libm@0.1.4
	lv2-atom@2.0.0
	lv2-core-derive@2.1.1
	lv2-core@3.0.0
	lv2-midi@1.2.0
	lv2-sys@2.0.0
	lv2-units@0.1.3
	lv2-urid@2.1.0
	lv2@0.6.0
	proc-macro2@1.0.69
	quote@1.0.33
	syn@1.0.109
	unicode-ident@1.0.12
	urid-derive@0.1.1
	urid@0.1.0
	wmidi@3.1.0
"

RUST_MIN_VER="1.72.0"

inherit cargo

# chadmed/bankstown, the commit alarm-aurora pins
COMMIT="8e6f96f06d0e51c2a1dc513cf2fdf57ab32a2a64"

DESCRIPTION="Bass enhancement LV2 plugin used by the Apple Silicon speaker profiles"
HOMEPAGE="https://github.com/chadmed/bankstown"
SRC_URI="
	https://github.com/chadmed/bankstown/archive/${COMMIT}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/bankstown-${COMMIT}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" MIT Unicode-DFS-2016"
SLOT="0"
KEYWORDS="~arm64"

DEPEND="media-libs/lv2"
RDEPEND="${DEPEND}"

QA_FLAGS_IGNORED="usr/lib.*/lv2/bankstown.lv2/bankstown.so"

src_prepare() {
	sed -i -e "s|target/release|$(cargo_target_dir)|" Makefile || die
	default
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install
	dodoc README.md
}
