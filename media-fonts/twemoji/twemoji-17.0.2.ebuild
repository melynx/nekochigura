# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Color emoji font with a flat visual style, designed and used by Twitter"
HOMEPAGE="https://github.com/jdecked/twemoji"
SRC_URI="https://github.com/JoeBlakeB/ttf-twemoji/releases/download/${PV}/Twemoji-${PV}.ttf"
S="${WORKDIR}"

LICENSE="Apache-2.0 CC-BY-4.0 MIT OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"

FONT_SUFFIX="ttf"
FONT_CONF=( "${FILESDIR}"/75-${PN}.conf )

src_unpack() {
	cp "${DISTDIR}/${A}" "${S}/${PN}.${FONT_SUFFIX}" || die
}
