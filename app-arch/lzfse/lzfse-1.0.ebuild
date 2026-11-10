# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Apple's LZFSE compression library and command line tool"
HOMEPAGE="https://github.com/lzfse/lzfse"
SRC_URI="https://github.com/lzfse/lzfse/archive/refs/tags/${P}.tar.gz"
S="${WORKDIR}/${PN}-${P}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm64"

src_configure() {
	local mycmakeargs=(
		-DLZFSE_BUNDLE_MODE=OFF
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
	)
	cmake_src_configure
}

src_test() {
	local i
	for (( i = 0; i < 200; i++ )); do
		echo "lzfse round trip ${i}"
	done > "${T}/in" || die
	"${BUILD_DIR}/lzfse" -encode -i "${T}/in" -o "${T}/in.lzfse" || die
	"${BUILD_DIR}/lzfse" -decode -i "${T}/in.lzfse" -o "${T}/out" || die
	cmp "${T}/in" "${T}/out" || die
}
