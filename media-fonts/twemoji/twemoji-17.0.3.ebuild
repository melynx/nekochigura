# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Color emoji font built from Twemoji artwork"
HOMEPAGE="
	https://github.com/jdecked/twemoji
	https://github.com/JoeBlakeB/ttf-twemoji
"
SRC_URI="https://github.com/JoeBlakeB/ttf-twemoji/releases/download/${PV}/Twemoji-${PV}.ttf"
S="${WORKDIR}"

LICENSE="Apache-2.0 CC-BY-4.0 MIT OFL-1.1"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

FONT_SUFFIX="ttf"
FONT_CONF=( "${FILESDIR}"/45-${PN}.conf )

src_unpack() {
	cp "${DISTDIR}/${A}" "${S}/${PN}.${FONT_SUFFIX}" || die
}

pkg_postinst() {
	font_pkg_postinst

	local old_conf="${EROOT}/etc/fonts/conf.d/75-${PN}.conf"
	if [[ -L ${old_conf} ]]; then
		ewarn "The enabled 75-${PN}.conf was replaced by a conservative priority-45 policy."
		ewarn "Remove the stale symlink at ${old_conf}, then run:"
		ewarn "  eselect fontconfig enable 45-${PN}.conf"
	fi
}
