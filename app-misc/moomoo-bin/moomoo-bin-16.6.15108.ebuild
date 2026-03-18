# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg-utils

MY_PN="${PN%-bin}"

DESCRIPTION="moomoo desktop trading platform (binary distribution)"
HOMEPAGE="https://www.moomoo.com/sg/"
SRC_URI="https://softwaredownload.futustatic.com/${MY_PN}_desktop_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

BDEPEND="$(unpacker_src_uri_depends)"

RDEPEND="
	dev-libs/glib:2
	dev-libs/nss
	dev-qt/qtwayland:5
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

QA_PREBUILT="opt/moomoo/*"

src_install() {
	insinto /opt/moomoo
	doins -r opt/moomoo/.

	# Make binaries executable
	local exe
	for exe in Launch moomoo CrashReporter FTWeb; do
		[[ -f "${ED}"/opt/moomoo/${exe} ]] && fperms +x /opt/moomoo/${exe}
	done

	# chrome-sandbox requires SUID for Chromium's sandbox to work
	fperms 4755 /opt/moomoo/chrome-sandbox

	# Remove bundled libstdc++ and libgcc_s to use system versions.
	# The bundled ones are too old (missing GLIBCXX_3.4.32) and break
	# NSS initialization, causing SIGTRAP crashes after login.
	rm "${ED}"/opt/moomoo/libstdc++.so.6 || die
	rm "${ED}"/opt/moomoo/libgcc_s.so.1 || die

	# Make shared libraries executable
	find "${ED}"/opt/moomoo -name "*.so*" -type f -exec chmod +x {} \; || die

	# Install wrapper script with Wayland support
	newbin "${FILESDIR}/${MY_PN}-wrapper.sh" ${MY_PN}

	# Install desktop file and icon
	domenu "${FILESDIR}/${MY_PN}.desktop"
	newicon opt/moomoo/app.png ${MY_PN}.png
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "moomoo has been installed to /opt/moomoo"
	elog "You can launch it from your application menu or by running:"
	elog "  moomoo"
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
