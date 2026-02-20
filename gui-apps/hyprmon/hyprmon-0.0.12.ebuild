# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="TUI tool for configuring monitors on Wayland with Hyprland"
HOMEPAGE="https://github.com/erans/hyprmon"
SRC_URI="
	https://github.com/erans/hyprmon/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://raw.githubusercontent.com/melynx/nekochigura-dependencies/master/gui-apps/${PN}/${P}-vendor.tar.xz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="gui-wm/hyprland"

src_compile() {
	ego build -ldflags "-s -w -X main.Version=${PV}" -o "${PN}" .
}

src_install() {
	dobin "${PN}"
}
