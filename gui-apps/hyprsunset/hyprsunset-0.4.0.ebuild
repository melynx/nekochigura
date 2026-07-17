# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="An application to enable a blue-light filter on Hyprland"
HOMEPAGE="https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/"
SRC_URI="https://github.com/hyprwm/${PN^}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	>=dev-libs/hyprlang-0.4.0:=
	dev-libs/wayland
	>=gui-libs/hyprutils-0.2.3:=
	>=gui-wm/hyprland-0.45.0
"
DEPEND="
	${RDEPEND}
	>=dev-libs/hyprland-protocols-0.4.0
	dev-libs/wayland-protocols
	>=dev-util/hyprwayland-scanner-0.4.0
	dev-util/wayland-scanner
"
BDEPEND="
	|| ( >=sys-devel/gcc-14:* >=llvm-core/clang-18:* )
	virtual/pkgconfig
"

PATCHES=( "${FILESDIR}"/${P}-archive-build.patch )

pkg_setup() {
	[[ ${MERGE_TYPE} == binary ]] && return

	tc-check-min_ver gcc 14
	tc-check-min_ver clang 18
}
