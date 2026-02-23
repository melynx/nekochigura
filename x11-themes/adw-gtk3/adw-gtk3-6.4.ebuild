# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The theme from libadwaita ported to GTK-3"
HOMEPAGE="https://github.com/lassekongo83/adw-gtk3"
SRC_URI="https://github.com/lassekongo83/adw-gtk3/releases/download/v${PV}/${PN}v${PV}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	x11-libs/gtk+:3
	>=gui-libs/gtk-4.16.0:4
"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/themes
	doins -r adw-gtk3 adw-gtk3-dark
}
