# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MICROTEX_COMMIT="0e3707f6dafebb121d98b53c64364d16fefe481d"

inherit cmake

DESCRIPTION="LaTeX rendering application for illogical-impulse dotfiles"
HOMEPAGE="https://github.com/NanoMichael/MicroTeX"
SRC_URI="
	https://github.com/NanoMichael/MicroTeX/archive/${MICROTEX_COMMIT}.tar.gz
		-> ${P}.tar.gz
"
S="${WORKDIR}/MicroTeX-${MICROTEX_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-cpp/cairomm:0
	dev-cpp/gtkmm:3.0
	dev-cpp/gtksourceviewmm:3.0
	dev-libs/tinyxml2:=
	media-libs/fontconfig:1.0
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-1.0-fontconfig-freetype-header.patch"
)

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DGRAPHICS_DEBUG=OFF
		-DHAVE_LOG=OFF
	)

	cmake_src_configure
}

src_install() {
	dolib.so "${BUILD_DIR}"/libLaTeX.so

	exeinto /opt/illogical-impulse-microtex-git
	doexe "${BUILD_DIR}"/LaTeX

	insinto /usr/share/clatexmath
	doins -r "${BUILD_DIR}"/res/.

	dodoc README.md
}
