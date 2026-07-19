# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd udev

DESCRIPTION="DisplayLink USB Graphics Software userspace driver daemon"
HOMEPAGE="https://www.synaptics.com/products/displaylink-graphics"
SRC_URI="https://www.synaptics.com/sites/default/files/exe_files/2026-06/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu${PV}-EXE.zip -> ${P}.zip"
S="${WORKDIR}/extracted"

LICENSE="
	BSD-2 Boost-1.0 DisplayLink GPL-2 LGPL-2.1+ MIT
	|| ( Apache-2.0 GPL-2+ )
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="systemd"
REQUIRED_USE="elibc_glibc"

RESTRICT="strip mirror bindist"
BDEPEND="app-arch/unzip"

RDEPEND="
	>=x11-drivers/evdi-1.14.0
	sys-apps/util-linux
	sys-libs/glibc
	virtual/libusb:1
	systemd? ( sys-apps/systemd )
	!systemd? ( sys-apps/openrc )
"

QA_PREBUILT="usr/libexec/displaylink/DisplayLinkManager"

# The license forbids modifying the proprietary prebuilt executable.
QA_FLAGS_IGNORED="usr/libexec/displaylink/DisplayLinkManager"
QA_RUNPATH="usr/libexec/displaylink/DisplayLinkManager"

src_unpack() {
	default

	local run_files=( "${WORKDIR}"/displaylink-driver-*.run )
	local run_file=${run_files[0]}
	[[ -f ${run_file} ]] || die "Could not find .run installer"

	chmod +x "${run_file}" || die

	# Extract the payload without running the installer.
	if ! sh "${run_file}" --noexec --target "${S}" 2>/dev/null; then
		einfo "Standard extraction failed, trying manual extraction..."
		mkdir -p "${S}" || die

		local marker
		marker=$(grep -anxm1 '__EOF__' "${run_file}" | cut -d: -f1)
		[[ -z ${marker} ]] && \
			marker=$(grep -anxm1 'exit 0' "${run_file}" | cut -d: -f1)
		[[ -z "${marker}" ]] && die "Could not find embedded archive marker"

		tail -n +$((marker + 1)) "${run_file}" | \
			tar -xzf - -C "${S}" || die
	fi
}

src_install() {
	local binary_dir
	case "${ARCH}" in
		amd64) binary_dir="x64-ubuntu-1604" ;;
		arm64) binary_dir="aarch64-linux-gnu" ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac
	[[ -x ${binary_dir}/DisplayLinkManager ]] || \
		die "Missing ${ARCH} DisplayLinkManager"

	exeinto /usr/libexec/displaylink
	doexe "${binary_dir}"/DisplayLinkManager

	insinto /usr/libexec/displaylink
	doins *.spkg

	if use systemd; then
		systemd_dounit "${FILESDIR}"/displaylink-driver.service
	else
		newinitd "${FILESDIR}"/displaylink-driver.initd displaylink-driver
	fi

	udev_dorules "${FILESDIR}"/99-displaylink.rules
	exeinto /usr/libexec/displaylink
	doexe "${FILESDIR}"/udev.sh

	dodoc LICENSE 3rd_party_licences.txt
	local release_notes=( "${WORKDIR}"/*-Release\ Notes.txt )
	[[ -f ${release_notes[0]} ]] && dodoc "${release_notes[0]}"
}

pkg_postinst() {
	udev_reload

	elog "DisplayLink USB Graphics driver has been installed."
	elog ""
	elog "To use DisplayLink devices:"
	elog "  1. Ensure the EVDI kernel module is loaded:"
	elog "     modprobe evdi"

	if use systemd; then
		elog "  2. Enable and start the DisplayLink service:"
		elog "     systemctl enable --now displaylink-driver.service"
	else
		elog "  2. Add the DisplayLink service to the default runlevel and start it:"
		elog "     rc-update add displaylink-driver default"
		elog "     rc-service displaylink-driver start"
	fi

	elog ""
	elog "After connecting a DisplayLink device, configure displays with:"
	elog "  xrandr --listproviders"
	elog "  xrandr --setprovideroutputsource 1 0"
	elog "  xrandr"
	elog ""
	ewarn "DisplayLink uses proprietary binary drivers."
	ewarn "Some features may not work with all hardware configurations."
	elog ""

	if use systemd; then
		elog "For troubleshooting, check:"
		elog "  journalctl -u displaylink-driver.service"
		elog "  dmesg | grep -i displaylink"
	fi
}

pkg_postrm() {
	udev_reload
}
