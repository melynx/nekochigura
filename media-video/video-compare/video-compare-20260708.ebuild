# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Split-screen video comparison tool using FFmpeg and SDL2"
HOMEPAGE="https://github.com/pixop/video-compare"
SRC_URI="https://github.com/pixop/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"

LICENSE="GPL-2+ MIT OFL-1.1 public-domain"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-libs/libsdl2:=
	media-libs/sdl2-ttf:=
	media-video/ffmpeg:0=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}/${PN}-0001-gentoo-build.patch" )

src_compile() {
	emake USE_PKG_CONFIG=1
}

src_install() {
	dobin video-compare
	einstalldocs
}
