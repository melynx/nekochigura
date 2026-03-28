# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg-utils

MY_PN="clash-party"

DESCRIPTION="Desktop GUI application for managing Mihomo proxy"
HOMEPAGE="https://clashparty.org https://github.com/mihomo-party-org/clash-party"
SRC_URI="https://github.com/mihomo-party-org/${MY_PN}/releases/download/v${PV}/${MY_PN}-linux-${PV}-amd64.deb -> ${P}-amd64.deb"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

BDEPEND="$(unpacker_src_uri_depends)"

RDEPEND="
	dev-libs/nss
	app-crypt/libsecret
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libXScrnSaver
	x11-libs/libXtst
"

QA_PREBUILT="opt/clash-party/*"

src_install() {
	insinto /opt
	doins -r opt/clash-party

	exeinto /opt/clash-party
	doexe opt/clash-party/mihomo-party
	doexe opt/clash-party/chrome_crashpad_handler
	doexe opt/clash-party/chrome-sandbox

	find "${ED}"/opt/clash-party -name "*.so*" -type f -exec chmod +x {} \; || die
	find "${ED}"/opt/clash-party/resources/sidecar -type f -exec chmod +x {} \; || die

	dosym ../../opt/clash-party/mihomo-party /usr/bin/clash-party

	domenu usr/share/applications/mihomo-party.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
