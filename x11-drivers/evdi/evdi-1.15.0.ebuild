# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Extensible Virtual Display Interface"
HOMEPAGE="https://github.com/DisplayLink/evdi"
SRC_URI="https://github.com/DisplayLink/evdi/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND+=" x11-libs/libdrm"
BDEPEND+=" virtual/pkgconfig"

CONFIG_CHECK="~DRM ~DRM_KMS_HELPER"

PATCHES=( "${FILESDIR}/${P}-check-proc-read.patch" )

src_compile() {
	local modlist=( evdi=misc:module )
	local modargs=(
		KDIR="${KV_OUT_DIR}"
		KVER="${KV_FULL}"
	)
	linux-mod-r1_src_compile

	emake -C library
}

src_install() {
	linux-mod-r1_src_install

	emake -C library \
		DESTDIR="${ED}" \
		LIBDIR="/usr/$(get_libdir)" \
		install
	doheader library/evdi_lib.h
}
