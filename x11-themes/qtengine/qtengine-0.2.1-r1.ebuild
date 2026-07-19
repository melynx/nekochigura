# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Configurable Qt platform theme using KDE color schemes"
HOMEPAGE="https://github.com/kossLAN/qtengine"
SRC_URI="https://github.com/kossLAN/qtengine/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

# Qt 6.9 and KDE Frameworks 6.20 are upstream's minimum versions. Qtengine
# uses Qt6::GuiPrivate, so the slot operator triggers rebuilds for private ABI
# changes. Qt Quick Controls support enables the configured style in QML apps
# and is expected by Caelestia's generated configuration.
COMMON_DEPEND="
	>=dev-qt/qtbase-6.9:6=[dbus,gui,widgets]
	>=dev-qt/qtdeclarative-6.9:6
	>=kde-frameworks/kcolorscheme-6.20
	>=kde-frameworks/kconfig-6.20
	>=kde-frameworks/kiconthemes-6.20
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
BDEPEND=">=kde-frameworks/extra-cmake-modules-6.20"

src_configure() {
	local mycmakeargs=(
		-DBUILD_QT5=OFF
		-DBUILD_QT6=ON
		# Upstream defaults to lib/qt6/plugins. Gentoo amd64 uses lib64.
		-DQT6_PLUGINDIR="$(get_libdir)/qt6/plugins"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install
	dodoc README.md
}

pkg_postinst() {
	elog "Set QT_QPA_PLATFORMTHEME=qtengine to enable the platform theme."
	elog "Configuration is read from ~/.config/qtengine/config.json."
	elog "Caelestia manages this file when Qt theming is enabled in its CLI."
}
