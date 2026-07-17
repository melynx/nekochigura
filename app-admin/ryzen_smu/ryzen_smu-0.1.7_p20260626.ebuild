# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Kernel driver for AMD Ryzen's System Management Unit"
HOMEPAGE="https://github.com/amkillam/ryzen_smu"

COMMIT="1be4fb1cd9d60b5ddefc2a4201a898766a731400"
SRC_URI="https://github.com/amkillam/${PN}/archive/${COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

CONFIG_CHECK="PCI"

src_compile() {
	local modlist=( ryzen_smu )
	local modargs=( KERNEL_BUILD="${KV_OUT_DIR}" )

	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install
}
