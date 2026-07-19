# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="The power management tool for mobile and desktop Ryzen APUs"
HOMEPAGE="https://github.com/FlyGoat/RyzenAdj"
SRC_URI="https://github.com/FlyGoat/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="sys-apps/pciutils"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}/${P}-respect-toolchain.patch" )

DOCS=( README.md )

src_configure() {
	append-cflags -ffile-prefix-map="${WORKDIR}"=.
	cmake_src_configure
}

src_install() {
	dosbin "${BUILD_DIR}"/ryzenadj

	dolib.so "${BUILD_DIR}"/libryzenadj.so
	doheader lib/ryzenadj.h

	einstalldocs
}
