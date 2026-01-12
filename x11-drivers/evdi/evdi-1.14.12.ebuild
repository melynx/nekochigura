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

DEPEND="virtual/linux-sources"
RDEPEND=""

CONFIG_CHECK="~DRM ~DRM_KMS_HELPER"

S="${WORKDIR}/${P}/module"

src_compile() {
	local modlist=( evdi=misc )
	local modargs=( KERNEL_SRC="${KV_OUT_DIR}" )
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install
	dodoc ../README.md
}
