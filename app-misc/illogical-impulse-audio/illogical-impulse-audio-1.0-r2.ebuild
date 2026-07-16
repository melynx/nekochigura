# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Illogical Impulse Audio Dependencies"
HOMEPAGE="https://github.com/end-4/dots-hyprland"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-sound/libcava
	media-sound/pavucontrol-qt
	media-video/wireplumber
	dev-libs/libdbusmenu[gtk3]
	media-sound/playerctl
"
