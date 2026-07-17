# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg-utils

MY_PN="${PN%-bin}"

DESCRIPTION="Moomoo desktop trading platform (binary distribution)"
HOMEPAGE="https://www.moomoo.com/"
SRC_URI="https://softwaredownload.futustatic.com/${MY_PN}_desktop_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

BDEPEND="
	app-misc/pax-utils
	dev-util/patchelf
	$(unpacker_src_uri_depends)
"

# Moomoo ships its own Qt 5, CEF, OpenSSL, ICU, and XCB platform plugin.
# These are the system libraries required by that bundled runtime.
RDEPEND="
	app-accessibility/at-spi2-core
	app-arch/bzip2
	app-arch/xz-utils
	dev-db/sqlite
	dev-lang/tcl:0/8.6
	dev-lang/tk:0/8.6
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libffi-compat:6
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl-compat:1.1.1
	media-libs/alsa-lib
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/libglvnd
	media-libs/libmng
	media-libs/libpulse
	media-libs/mesa[gbm(+)]
	media-libs/tiff-compat:4
	net-print/cups
	sys-apps/dbus
	sys-libs/db:5.3
	sys-libs/ncurses-compat:5
	virtual/libcrypt:=
	virtual/zlib
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

QA_PREBUILT="opt/moomoo/*"

src_prepare() {
	default

	# Retain relocatable runtime paths, but remove relative current-directory
	# entries, empty entries, and paths from upstream's Jenkins build hosts.
	local elf_type elf rpath entry sanitized
	local -a entries kept
	while IFS=";" read -r elf_type elf rpath; do
		[[ ${elf_type} == ET_DYN || ${elf_type} == ET_EXEC ]] || continue
		[[ -n ${rpath} ]] || continue

		kept=()
		IFS=: read -ra entries <<< "${rpath}"
		for entry in "${entries[@]}"; do
			entry=${entry//\'/}
			[[ ${entry} == '$ORIGIN'* ]] || continue
			has "${entry}" "${kept[@]}" || kept+=( "${entry}" )
		done

		if (( ${#kept[@]} )); then
			printf -v sanitized "%s:" "${kept[@]}"
			patchelf --set-rpath "${sanitized%:}" "${elf}" || die
		else
			patchelf --remove-rpath "${elf}" || die
		fi
	done < <(scanelf -R -BF "#r%o;%F;%r" opt/moomoo)

	# The crash reporter does not use executable-stack trampolines.
	patchelf --clear-execstack opt/moomoo/CrashReporter || die

	# Gentoo's bzip2 intentionally uses the shorter ABI-equivalent SONAME.
	patchelf --replace-needed libbz2.so.1.0 libbz2.so.1 \
		opt/moomoo/PythonEnv/Python/lib/python3.8/lib-dynload/_bz2.*.so || die

	# No current Gentoo compatibility packages provide these two obsolete
	# SONAMEs. They are optional stdlib modules, not part of Moomoo's quant
	# entrypoint; omit the unusable extensions instead of adding false deps.
	rm opt/moomoo/PythonEnv/Python/lib/python3.8/lib-dynload/{_gdbm,readline}.*.so || die
}

src_install() {
	dodir /opt
	cp -a opt/moomoo "${ED}"/opt/ || die
	fowners -R root:root /opt/moomoo

	# Prefer the system compiler runtime. The bundled GCC 9-era libraries are
	# too old for libraries built by current Gentoo toolchains.
	rm "${ED}"/opt/moomoo/libstdc++.so.6 || die
	rm "${ED}"/opt/moomoo/libgcc_s.so.1 || die

	# Upstream ships chrome-sandbox as 0755 and uses the user-namespace
	# sandbox. Do not grant the proprietary helper setuid privileges.
	fperms 0755 /opt/moomoo/chrome-sandbox

	# Use Moomoo's private Qt runtime without enabling upstream's permanent
	# QT_DEBUG_PLUGINS logging.
	newbin "${FILESDIR}/${MY_PN}-wrapper.sh" ${MY_PN}

	domenu "${FILESDIR}/${MY_PN}.desktop"
	newicon opt/moomoo/app.png ${MY_PN}.png
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "Moomoo has been installed to /opt/moomoo"
	elog "You can launch it from your application menu or by running:"
	elog "  moomoo"
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
