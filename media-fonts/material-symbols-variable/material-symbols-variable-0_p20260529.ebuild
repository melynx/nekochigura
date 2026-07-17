# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Material Design icons by Google - variable fonts"
HOMEPAGE="https://github.com/google/material-design-icons"

BASE_URL="https://github.com/google/material-design-icons/raw/fef175fe"
FONT_URL="${BASE_URL}/variablefont"

SRC_URI="
	${FONT_URL}/MaterialSymbolsOutlined%5BFILL,GRAD,opsz,wght%5D.ttf ->
		MaterialSymbolsOutlined-FILL-GRAD-opsz-wght-${PV}.ttf
	${FONT_URL}/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.ttf ->
		MaterialSymbolsRounded-FILL-GRAD-opsz-wght-${PV}.ttf
	${FONT_URL}/MaterialSymbolsSharp%5BFILL,GRAD,opsz,wght%5D.ttf ->
		MaterialSymbolsSharp-FILL-GRAD-opsz-wght-${PV}.ttf
"

S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

FONT_SUFFIX="ttf"

src_unpack() {
	mkdir -p "${S}"
	cp "${DISTDIR}/MaterialSymbolsOutlined-FILL-GRAD-opsz-wght-${PV}.ttf" \
		"${S}/MaterialSymbolsOutlined[FILL,GRAD,opsz,wght].ttf"
	cp "${DISTDIR}/MaterialSymbolsRounded-FILL-GRAD-opsz-wght-${PV}.ttf" \
		"${S}/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf"
	cp "${DISTDIR}/MaterialSymbolsSharp-FILL-GRAD-opsz-wght-${PV}.ttf" \
		"${S}/MaterialSymbolsSharp[FILL,GRAD,opsz,wght].ttf"
}

src_install() {
	font_src_install
}
