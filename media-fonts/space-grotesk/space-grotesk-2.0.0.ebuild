# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A proportional sans-serif typeface variant based on Space Mono"
HOMEPAGE="https://github.com/floriankarsten/space-grotesk"
SRC_URI="https://github.com/floriankarsten/space-grotesk/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

S="${WORKDIR}/${P}"

FONT_S="${S}/fonts/otf"
FONT_SUFFIX="otf"

src_install() {
	font_src_install

	dodoc OFL.txt README.md AUTHORS.txt CONTRIBUTORS.txt
}
