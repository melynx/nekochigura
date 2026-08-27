# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit desktop distutils-r1 optfeature xdg-utils

DESCRIPTION="Output management utility for sway, Hyprland and Niri"
HOMEPAGE="https://github.com/nwg-piotr/nwg-displays"
SRC_URI="https://github.com/nwg-piotr/nwg-displays/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	gui-libs/gtk-layer-shell[introspection]
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}"

python_install_all() {
	distutils-r1_python_install_all
	domenu nwg-displays.desktop
	doicon nwg-displays.svg
}

pkg_postinst() {
	xdg_desktop_database_update
	optfeature "sway support" dev-python/i3ipc
	optfeature "Niri support" gui-wm/niri
	optfeature "wallpaper management on Hyprland" gui-apps/hyprpaper
	optfeature "wallpaper management on sway" gui-apps/swaybg
}

pkg_postrm() {
	xdg_desktop_database_update
}
