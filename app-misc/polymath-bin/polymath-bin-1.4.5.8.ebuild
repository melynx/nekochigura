# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop udev unpacker xdg-utils

MY_PN="${PN%-bin}"

DESCRIPTION="Flux Keyboard configurator (binary distribution)"
HOMEPAGE="https://fluxkeyboard.com/updates/"
SRC_URI="https://fluxkeyboard.com/updates/${MY_PN}/linux/deb/${MY_PN}_${PV}_amd64.deb"
S="${WORKDIR}"

# Polymath is proprietary. The bundle also carries a GPL build of FFmpeg 4
# (--enable-gpl: x264, x265, xvid), mpv, the BSD-licensed Flutter engine and
# BSD/ISC codec libraries (aom, dav1d, libvpx, opus, libsodium).
LICENSE="all-rights-reserved BSD BSD-2 GPL-2+ ISC LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

BDEPEND="
	app-misc/pax-utils
	dev-util/patchelf
	$(unpacker_src_uri_depends)
"

# Polymath ships its own Flutter runtime, media stack and plugins in
# /opt/polymath/lib. These are the system libraries that bundle links against,
# plus the tools its desktop-integration bridges call (curl, secret-tool).
RDEPEND="
	app-accessibility/at-spi2-core
	app-arch/xz-utils
	app-crypt/libsecret
	app-crypt/mit-krb5
	dev-libs/ayatana-ido
	dev-libs/fribidi
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/libayatana-indicator
	dev-libs/libbsd
	dev-libs/libdbusmenu
	dev-libs/libgcrypt
	dev-libs/libgpg-error
	dev-libs/libusb:1
	dev-libs/libxml2-compat:2
	dev-libs/nettle
	dev-libs/wayland
	|| (
		dev-libs/openssl-compat:3
		dev-libs/openssl:0/3
	)
	gnome-base/librsvg:2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/libepoxy
	media-libs/libglvnd
	media-libs/libpng
	media-libs/libpulse
	media-libs/libva
	media-libs/libwebp
	media-libs/mesa[gbm(+)]
	net-libs/gnutls
	net-misc/curl
	sys-devel/gcc[openmp]
	virtual/libudev
	virtual/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libvdpau
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/libxkbcommon
	x11-libs/libXpresent
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXv
	x11-libs/pango
"

QA_PREBUILT="opt/polymath/*"

src_prepare() {
	default

	# Keep $ORIGIN runpaths; drop the Flutter plugins' build-host path
	# (/work/polymath/linux/flutter/ephemeral).
	local elf_type elf rpath entry sanitized
	local -a entries kept
	while IFS=";" read -r elf_type elf rpath; do
		[[ ${elf_type} == ET_DYN || ${elf_type} == ET_EXEC ]] || continue
		[[ -n ${rpath} ]] || continue

		kept=()
		IFS=: read -ra entries <<< "${rpath}"
		for entry in "${entries[@]}"; do
			[[ ${entry} == '$ORIGIN'* ]] || continue
			has "${entry}" "${kept[@]}" || kept+=( "${entry}" )
		done

		if (( ${#kept[@]} )); then
			printf -v sanitized "%s:" "${kept[@]}"
			patchelf --set-rpath "${sanitized%:}" "${elf}" || die
		else
			patchelf --remove-rpath "${elf}" || die
		fi
	done < <(scanelf -R -BF "#r%o;%F;%r" opt/polymath)
}

src_install() {
	dodir /opt
	cp -a opt/polymath "${ED}"/opt/ || die
	fowners -R root:root /opt/polymath
	dosym -r /opt/polymath/polymath /usr/bin/${MY_PN}

	domenu usr/share/applications/com.fluxkeyboard.polymath.desktop
	doicon usr/share/pixmaps/polymath.png

	# Upstream's rule makes the devices world-writable; ours uses uaccess.
	udev_dorules "${FILESDIR}"/70-flux-keyboard.rules

	# Lets the session mount the RP2040 bootloader drive (RPI-RP2) for
	# firmware updates without a polkit prompt.
	insinto /usr/share/polkit-1/rules.d
	doins etc/polkit-1/rules.d/10-rpi-rp2-mount.rules
}

pkg_postinst() {
	udev_reload
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "Polymath has been installed to /opt/polymath; run it as: polymath"
	elog "Replug the keyboard so the new udev rule grants your session access."
}

pkg_postrm() {
	udev_reload
	xdg_desktop_database_update
	xdg_icon_cache_update
}
