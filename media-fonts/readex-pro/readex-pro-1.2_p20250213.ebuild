# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

MY_COMMIT="563dfbb36ae45e52ec50829b016ce724ac2fca70"

DESCRIPTION="Latin and Arabic font family designed for improved reading fluency"
HOMEPAGE="https://github.com/ThomasJockin/readexpro"
SRC_URI="https://github.com/ThomasJockin/readexpro/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/readexpro-${MY_COMMIT}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
RESTRICT="strip"

FONT_S="${S}/fonts/ttf"
FONT_SUFFIX="ttf"

DOCS=( AUTHORS.txt CONTRIBUTORS.txt README.md )
