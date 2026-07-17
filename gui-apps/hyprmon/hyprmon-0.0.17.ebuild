# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="TUI tool for configuring monitors on Wayland with Hyprland"
HOMEPAGE="https://github.com/erans/hyprmon"
SRC_URI="
	amd64? (
		https://github.com/erans/hyprmon/releases/download/v${PV}/hyprmon-linux-amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/erans/hyprmon/releases/download/v${PV}/hyprmon-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD MIT Unicode-3.0 Unicode-DFS-2016"
SLOT="0"
KEYWORDS="amd64 arm64"

RESTRICT="strip"

RDEPEND="gui-wm/hyprland"

QA_PREBUILT="usr/bin/hyprmon"

src_install() {
	local binary
	case ${ARCH} in
		amd64) binary="hyprmon-linux-amd64" ;;
		arm64) binary="hyprmon-linux-arm64" ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	newbin "${binary}" hyprmon
	dodoc README.md LICENSE "${FILESDIR}"/THIRD-PARTY-NOTICES
}
