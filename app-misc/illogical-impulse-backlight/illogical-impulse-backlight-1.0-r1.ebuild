# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Illogical Impulse Backlight Dependencies"
HOMEPAGE=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
RESTRICT="strip"

DEPEND=""
RDEPEND="
	app-misc/geoclue
	app-misc/brightnessctl
	app-misc/ddcutil
"
