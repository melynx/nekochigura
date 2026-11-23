# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit chromium-2 desktop optfeature unpacker xdg

MY_PN="clash-party"

DESCRIPTION="Desktop GUI application for managing Mihomo proxy"
HOMEPAGE="https://clashparty.org https://github.com/mihomo-party-org/clash-party"
SRC_URI="https://github.com/mihomo-party-org/${MY_PN}/releases/download/v${PV}/${MY_PN}-linux-${PV}-amd64.deb -> ${P}-amd64.deb"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror strip"

BDEPEND="$(unpacker_src_uri_depends)"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-auth/polkit
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/clash-party/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	insinto /opt
	doins -r opt/clash-party

	exeinto /opt/clash-party
	doexe opt/clash-party/mihomo-party
	doexe opt/clash-party/chrome_crashpad_handler
	doexe opt/clash-party/chrome-sandbox

	find "${ED}"/opt/clash-party -name "*.so*" -type f -exec chmod +x {} \; || die
	find "${ED}"/opt/clash-party/resources/sidecar -type f -exec chmod +x {} \; || die
	fperms 4755 /opt/clash-party/chrome-sandbox

	dosym ../../opt/clash-party/mihomo-party /usr/bin/clash-party

	domenu usr/share/applications/mihomo-party.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "system tray integration" dev-libs/libayatana-appindicator
}
