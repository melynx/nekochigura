# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# aurora-silicon/alsa-ucm-conf-asahi, the commit alarm-aurora pins (10.aurora2-5)
COMMIT="099f2b9c32609a7eb7d4c2c4987692bbc02de1bd"

DESCRIPTION="ALSA UCM profiles for Apple Silicon Macs (Aurora Silicon)"
HOMEPAGE="https://github.com/aurora-silicon/alsa-ucm-conf-asahi"
SRC_URI="https://github.com/aurora-silicon/alsa-ucm-conf-asahi/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/alsa-ucm-conf-asahi-${COMMIT}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm64"

RDEPEND="
	>=media-libs/alsa-lib-1.2.1
	media-libs/alsa-ucm-conf
	!media-libs/alsa-ucm-conf-asahi
"

src_install() {
	insinto /usr/share/alsa
	doins -r ucm2
	dodoc README.asahi README.J616s.md
}
