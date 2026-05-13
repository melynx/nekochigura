# Copyright 2025 Lucien Cartier-Tilet
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Linux kernel driver for embedded controller on Sixunited AXB35-02 boards"
HOMEPAGE="https://github.com/cmetz/ec-su_axb35-linux"

COMMIT="e483ec93deab514c66d3e5c9eeed98b6c17887b4"
SRC_URI="https://github.com/cmetz/ec-su_axb35-linux/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/ec-su_axb35-linux-${COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

src_compile() {
	local modlist=( ec_su_axb35 )
	local modargs=( KERNEL_BUILD="${KV_OUT_DIR}" )

	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	dobin scripts/su_axb35_monitor

	insinto /usr/lib/modules-load.d
	doins "${FILESDIR}"/ec_su_axb35.conf

	dodoc README.md
}
