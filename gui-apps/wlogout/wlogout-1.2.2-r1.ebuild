# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Wayland-based logout menu"
HOMEPAGE="https://github.com/ArtsyMacaw/wlogout"

if [[ "${PV}" = 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ArtsyMacaw/wlogout.git"
else
	SRC_URI="https://github.com/ArtsyMacaw/wlogout/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

DEPEND="
	gui-libs/gtk-layer-shell
	x11-libs/gtk+:3[wayland]
"
RDEPEND="${DEPEND}"
BDEPEND="
	app-text/scdoc
	virtual/pkgconfig
"

DOCS=(
	example.png
	README.md
)

src_configure() {
	local emesonargs=( -Dman-pages=enabled )
	meson_src_configure
}
