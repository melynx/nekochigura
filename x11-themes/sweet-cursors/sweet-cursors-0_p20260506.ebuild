# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_COMMIT="5ce81a45f0f0b63cf732317e7f91f3467ccce084"

DESCRIPTION="Colorful gradient XCursor theme based on Breeze"
HOMEPAGE="https://github.com/EliverLara/Sweet https://store.kde.org/p/1393084/"
SRC_URI="https://github.com/EliverLara/Sweet/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Sweet-${EGIT_COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

src_install() {
	insinto /usr/share/icons
	doins -r kde/cursors/Sweet-cursors

	# Caelestia refers to this theme using the lowercase package name.
	dosym Sweet-cursors /usr/share/icons/sweet-cursors
}
