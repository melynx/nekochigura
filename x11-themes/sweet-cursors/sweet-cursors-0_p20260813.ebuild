# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Head of the "nova" branch on 2026-08-13. The cursors live only on that
# branch: master dropped kde/ entirely, so a master snapshot has nothing to
# install (the first 0_p20260813 pointed at master and failed in doins).
EGIT_COMMIT="46e3802d3f4d9e992f94264f1d834f5f9621c03b"

DESCRIPTION="Colorful gradient XCursor theme based on Breeze"
HOMEPAGE="https://github.com/EliverLara/Sweet https://store.kde.org/p/1393084/"
SRC_URI="https://github.com/EliverLara/Sweet/archive/${EGIT_COMMIT}.tar.gz -> ${P}-${EGIT_COMMIT:0:7}.tar.gz"
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
