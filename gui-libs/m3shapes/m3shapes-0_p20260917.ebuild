# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# Untagged upstream; pins master. caelestia-shell 2.5.0's flake.nix still
# references 32ad9ce, but the QML module (URI M3Shapes 1.0) is unchanged.
EGIT_COMMIT="8a6fe8961749887d677700b6508e0c9249968b7e"

DESCRIPTION="Qt/QML port of the androidx Material 3 rounded-polygon shape library"
HOMEPAGE="https://github.com/soramanew/m3shapes"
SRC_URI="https://github.com/soramanew/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Upstream: qt_standard_project_setup(REQUIRES 6.8).
DEPEND="
	>=dev-qt/qtbase-6.8:6[gui]
	>=dev-qt/qtdeclarative-6.8:6
"
# caelestia-shell built this module in-tree up to 2.3.0 and installs the same
# four files under /usr/lib64/qt6/qml/M3Shapes, so the old one has to be gone
# before this package lands.
RDEPEND="
	${DEPEND}
	!<gui-apps/caelestia-shell-2.4.0
"
BDEPEND="
	>=dev-qt/qtshadertools-6.8:6
"

src_configure() {
	local mycmakeargs=(
		# Upstream now installs through GNUInstallDirs, so the eclass's /usr
		# prefix is right; pin the QML dir to where Gentoo's Qt6 looks.
		-DINSTALL_QMLDIR="$(get_libdir)/qt6/qml"
		-DM3SHAPES_BUILD_EXAMPLES=OFF
		# Qt's project setup adds $ORIGIN:$ORIGIN/../lib64 to the backing
		# library and upstream gives the plugin an rpath to the libdir; the
		# library now lives in the system libdir, so neither is needed.
		-DCMAKE_SKIP_INSTALL_RPATH=ON
	)
	cmake_src_configure
}
