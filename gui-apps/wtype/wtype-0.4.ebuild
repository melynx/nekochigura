# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="xdotool type for wayland"
HOMEPAGE="https://github.com/atx/wtype"
SRC_URI="https://github.com/atx/wtype/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=( "${FILESDIR}/${P}-deterministic-version.patch" )

DEPEND="dev-libs/wayland
	x11-libs/libxkbcommon"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-util/wayland-scanner
	virtual/pkgconfig
"
