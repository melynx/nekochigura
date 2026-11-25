# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# nekochigura: ::gentoo's sbctl-0.18, unchanged except KEYWORDS. ::gentoo has
# no arm64 keyword; this copy is for neko-rockpi4c-rk3399 (U-Boot UEFI Secure
# Boot). Only ~arm64: this overlay outranks ::gentoo at equal versions, so
# amd64 machines keep resolving to ::gentoo's ~amd64 ebuild.

EAPI=8

inherit go-module optfeature verify-sig

DESCRIPTION="Secure Boot key manager"
HOMEPAGE="https://github.com/Foxboron/sbctl"
SRC_URI="https://github.com/Foxboron/${PN}/releases/download/${PV}/${P}.tar.gz
	verify-sig? ( https://github.com/Foxboron/${PN}/releases/download/${PV}/${P}.tar.gz.sig )"
SRC_URI+=" https://dev.gentoo.org/~ajak/distfiles/${CATEGORY}/${PN}/${P}-deps.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 MIT"
# Dependent licenses
LICENSE+="  Apache-2.0 BSD BSD-2 GPL-2 MIT"
# Dependent licenses
LICENSE+="  "
SLOT="0"
KEYWORDS="~arm64"

DEPEND="sys-apps/pcsc-lite"

BDEPEND="app-text/asciidoc
	verify-sig? ( sec-keys/openpgp-keys-foxboron )"

VERIFY_SIG_OPENPGP_KEY_PATH="/usr/share/openpgp-keys/foxboron.asc"

src_unpack() {
	if use verify-sig; then
		verify-sig_verify_detached "${DISTDIR}"/${P}.tar.gz{,.sig}
	fi

	default
}

src_install() {
	emake PREFIX="${ED}/usr" install
}

pkg_postinst() {
	optfeature "automatically signing installed kernels with sbctl keys on each kernel installation" \
		"sys-kernel/installkernel[systemd]"
}
