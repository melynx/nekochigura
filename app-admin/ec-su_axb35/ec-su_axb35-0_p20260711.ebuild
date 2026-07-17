# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Linux kernel driver for embedded controller on Sixunited AXB35-02 boards"
HOMEPAGE="https://github.com/cmetz/ec-su_axb35-linux"

COMMIT="7a9f372edcaa99e562dece70204c4f609692a778"
SRC_URI="https://github.com/cmetz/ec-su_axb35-linux/archive/${COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/ec-su_axb35-linux-${COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

CONFIG_CHECK="ACPI_EC"

src_compile() {
	local modlist=( ec_su_axb35 )
	local modargs=( KERNEL_BUILD="${KV_OUT_DIR}" )

	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	dobin scripts/su_axb35_monitor
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst

	ewarn "The ec_su_axb35 module directly accesses board-specific EC registers"
	ewarn "and does not detect compatible hardware. It is not loaded automatically."
	ewarn "Only on a supported Sixunited AXB35-02 board, load it with:"
	ewarn "  modprobe ec_su_axb35"
	ewarn "To load it at boot, add ec_su_axb35 to a file under /etc/modules-load.d/."
}
