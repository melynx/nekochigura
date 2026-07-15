# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg-utils

DESCRIPTION="WeChat desktop client for Linux (binary distribution)"
HOMEPAGE="https://linux.weixin.qq.com/"
SRC_URI="https://sim.debiancn.org/debiancn/pool/main/w/wechat-stable/wechat_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

BDEPEND="
	dev-util/patchelf
	$(unpacker_src_uri_depends)
"

RDEPEND="
	app-crypt/mit-krb5
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-fonts/noto-cjk
	media-libs/fontconfig
	media-libs/libpulse
	sys-apps/dbus
	virtual/udev
	virtual/zlib
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

QA_PREBUILT="opt/wechat/*"

src_prepare() {
	default

	local elf
	local -a bundled_elfs=(
		opt/wechat/libconfService.so
		opt/wechat/libilink2.so
		opt/wechat/libilink_network.so
		opt/wechat/libroam_migration.so
		opt/wechat/libvoipChannel.so
		opt/wechat/libvoipCodec.so
		opt/wechat/RadiumWMPF/runtime/libilink2.so
		opt/wechat/RadiumWMPF/runtime/libilink_network.so
	)

	for elf in "${bundled_elfs[@]}"; do
		patchelf --set-rpath '${ORIGIN}' "${elf}" || die
	done
}

src_install() {
	# Install main application directory
	insinto /opt
	doins -r opt/wechat

	# Make binaries executable
	exeinto /opt/wechat
	doexe opt/wechat/wechat
	doexe opt/wechat/wxocr
	doexe opt/wechat/wxplayer
	doexe opt/wechat/wxutility
	doexe opt/wechat/crashpad_handler

	# Make shared libraries executable
	find "${ED}"/opt/wechat -name "*.so*" -type f -exec chmod +x {} \; || die

	# Make additional executables in subdirectories executable
	if [[ -f "${ED}"/opt/wechat/RadiumWMPF/runtime/WeChatAppEx ]]; then
		fperms +x /opt/wechat/RadiumWMPF/runtime/WeChatAppEx
	fi
	if [[ -f "${ED}"/opt/wechat/RadiumWMPF/runtime/crashpad_handler ]]; then
		fperms +x /opt/wechat/RadiumWMPF/runtime/crashpad_handler
	fi

	# Install wrapper script
	newbin "${FILESDIR}/wechat-wrapper" wechat

	# Install desktop file and icons
	domenu usr/share/applications/wechat.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor

	# Install documentation
	if [[ -f usr/share/doc/wechat/changelog.gz ]]; then
		gzip -cd usr/share/doc/wechat/changelog.gz > "${T}"/changelog || die
		dodoc "${T}"/changelog
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "WeChat has been installed to /opt/wechat"
	elog "You can launch it from your application menu or by running:"
	elog "  wechat"
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
