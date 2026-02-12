EAPI=8

DESCRIPTION="Split-screen video comparison tool using FFmpeg and SDL2"
HOMEPAGE="https://github.com/pixop/video-compare"

MY_PN="video-compare"
SRC_URI="https://github.com/pixop/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-video/ffmpeg:0=
	media-libs/libsdl2:=
	media-libs/sdl2-ttf:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${MY_PN}-${PV}"

PATCHES=( "${FILESDIR}/${PN}-0001-gentoo-build.patch" )

src_compile() {
	emake USE_PKG_CONFIG=1
}

src_install() {
	dobin video-compare
	einstalldocs
}
