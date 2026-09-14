# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open source, compact, material-designed cursor set"
HOMEPAGE="https://github.com/ful1e5/Bibata_Cursor"
SRC_URI="https://github.com/ful1e5/Bibata_Cursor/releases/download/v${PV}/Bibata.tar.xz -> ${P}.tar.xz"

S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# The same cursor files shipped as x11-misc/bibata-modern-classic before the
# rename; without the blocker the two collide on every machine that had it.
RDEPEND="x11-libs/libXcursor
	!x11-misc/bibata-modern-classic"

src_install() {
	insinto /usr/share/icons
	doins -r Bibata-{Modern,Original}-{Amber,Classic,Ice}{,-Right}
}
