# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Extensible Virtual Display Interface"
HOMEPAGE="https://github.com/DisplayLink/evdi"
SRC_URI="https://github.com/DisplayLink/evdi/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	virtual/linux-sources
	x11-libs/libdrm
"
RDEPEND="x11-libs/libdrm"

CONFIG_CHECK="~DRM ~DRM_KMS_HELPER"

src_compile() {
	# Build kernel module
	cd "${WORKDIR}/${P}/module" || die
	local modlist=( evdi=misc )
	local modargs=(
		KDIR="${KV_OUT_DIR}"
		KVER="${KV_FULL}"
	)
	linux-mod-r1_src_compile

	# Build userspace library
	cd "${WORKDIR}/${P}/library" || die
	emake
}

src_install() {
	# Install kernel module
	cd "${WORKDIR}/${P}/module" || die
	linux-mod-r1_src_install

	# Install userspace library
	cd "${WORKDIR}/${P}/library" || die
	emake DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)" install

	# Install documentation
	cd "${WORKDIR}/${P}" || die
	dodoc README.md
}
