# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg-utils

MY_PN="${PN%-bin}"

DESCRIPTION="ChatGPT desktop app by OpenAI with the Codex agent (binary distribution)"
HOMEPAGE="https://developers.openai.com/codex/app"
SRC_URI="https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/${MY_PN}/${MY_PN}_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

BDEPEND="$(unpacker_src_uri_depends)"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-arch/xz-utils
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libusb:1
	dev-libs/nspr
	dev-libs/nss
	dev-vcs/git
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/chatgpt/*"

src_prepare() {
	default

	# The bundled node modules carry native prebuilds for every platform
	# they target (android, arm, arm64, musl). Only the linux-x64 glibc
	# builds can ever load here; the rest are dead weight that trips the
	# unresolved-soname QA scan.
	local d
	while IFS= read -r -d "" d; do
		find "${d}" -mindepth 1 -maxdepth 1 -type d ! -name "*linux-x64*" \
			-exec rm -r {} + || die
		find "${d}" -name "*musl*" -prune -exec rm -r {} + || die
	done < <(find usr/lib/${MY_PN} -type d -name prebuilds -print0)
}

src_install() {
	# The deb also ships an AppArmor userns grant for Ubuntu 24.04+ and an
	# apt-repository postinst; neither applies here. Install only the app
	# tree, relocated from /usr/lib/chatgpt to /opt per prebuilt convention
	# (the launcher resolves its own path, nothing references /usr/lib).
	dodir /opt
	cp -a usr/lib/${MY_PN} "${ED}"/opt/ || die
	fowners -R root:root /opt/${MY_PN}

	newbin "${FILESDIR}"/${MY_PN}-wrapper ${MY_PN}

	domenu usr/share/applications/${MY_PN}.desktop
	doicon usr/share/pixmaps/${MY_PN}.png
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "ChatGPT (Codex) has been installed to /opt/chatgpt"
	elog "You can launch it from your application menu or by running:"
	elog "  chatgpt"
	elog
	elog "No setuid chrome-sandbox is shipped: the Chromium sandbox requires"
	elog "unprivileged user namespaces (CONFIG_USER_NS=y, not restricted by"
	elog "sysctl). The app self-updates via apt on Debian systems only; here,"
	elog "updates arrive by bumping this ebuild."
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
