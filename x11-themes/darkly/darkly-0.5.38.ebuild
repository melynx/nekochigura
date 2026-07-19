# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Modern Qt application style and Plasma decoration"
HOMEPAGE="https://github.com/Bali10050/Darkly"
SRC_URI="https://github.com/Bali10050/Darkly/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Darkly-${PV}"

LICENSE="GPL-2+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-qt/qtbase-6.7:6[dbus,gui,widgets]
	>=dev-qt/qtdeclarative-6.7:6[widgets]
	>=kde-frameworks/frameworkintegration-6.10:6
	>=kde-frameworks/kcmutils-6.10:6
	>=kde-frameworks/kcolorscheme-6.10:6
	>=kde-frameworks/kconfig-6.10:6
	>=kde-frameworks/kconfigwidgets-6.10:6
	>=kde-frameworks/kcoreaddons-6.10:6
	>=kde-frameworks/kguiaddons-6.10:6
	>=kde-frameworks/ki18n-6.10:6
	>=kde-frameworks/kiconthemes-6.10:6
	>=kde-frameworks/kirigami-6.10:6
	>=kde-frameworks/kwindowsystem-6.10:6
	kde-plasma/kdecoration:6
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=kde-frameworks/extra-cmake-modules-6.10
	sys-devel/gettext
"

PATCHES=(
	"${FILESDIR}/${P}-enable-tests.patch"
	"${FILESDIR}/${P}-initialize-tab-side.patch"
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_QT5=OFF
		-DBUILD_QT6=ON
		-DBUILD_TESTING=$(usex test)
		-DWITH_DECORATIONS=ON
	)
	cmake_src_configure
}

src_test() {
	local -x QT_QPA_PLATFORM=offscreen
	cmake_src_test
}

src_install() {
	cmake_src_install
	dodoc README.md
}
