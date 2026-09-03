# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# Untagged upstream. Pin the revision caelestia-shell's flake.nix references,
# which is also master at the time of writing.
EGIT_COMMIT="32ad9ce328bb77ed349b40a3be10ee9ea610b8ab"

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
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-qt/qtshadertools-6.8:6
"

src_configure() {
	local mycmakeargs=(
		# Upstream's install() destinations are relative ("usr/lib/qt6/qml/..."),
		# so the prefix has to be "/" or they land under /usr/usr.
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/"
		# Gentoo ships Qt6 QML under lib64; the upstream default usr/lib/qt6/qml
		# would put the module where Quickshell does not look for it.
		-DINSTALL_QMLDIR=usr/lib64/qt6/qml
		-DM3SHAPES_BUILD_EXAMPLES=OFF
	)
	cmake_src_configure
}
