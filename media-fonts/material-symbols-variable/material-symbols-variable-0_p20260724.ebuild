# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Material Design icons by Google - variable fonts"
HOMEPAGE="https://github.com/google/material-design-icons"

COMMIT="528cb964c01fb2b09bc3b9208f82b6d8f8c1c1e2"
BASE_URL="https://raw.githubusercontent.com/google/material-design-icons/${COMMIT}/variablefont"

SRC_URI="
	${BASE_URL}/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf ->
		MaterialSymbolsOutlined-FILL-GRAD-opsz-wght-${PV}.ttf
	${BASE_URL}/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf ->
		MaterialSymbolsRounded-FILL-GRAD-opsz-wght-${PV}.ttf
	${BASE_URL}/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf ->
		MaterialSymbolsSharp-FILL-GRAD-opsz-wght-${PV}.ttf
"

S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

FONT_SUFFIX="ttf"

src_unpack() {
	local style

	mkdir -p "${S}" || die
	for style in Outlined Rounded Sharp; do
		cp "${DISTDIR}/MaterialSymbols${style}-FILL-GRAD-opsz-wght-${PV}.ttf" \
			"${S}/MaterialSymbols${style}[FILL,GRAD,opsz,wght].ttf" || die
	done
}

src_install() {
	font_src_install
}
