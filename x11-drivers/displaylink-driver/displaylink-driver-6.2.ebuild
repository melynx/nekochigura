# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd udev

DESCRIPTION="DisplayLink USB Graphics Software userspace driver daemon"
HOMEPAGE="https://www.synaptics.com/products/displaylink-graphics"
SRC_URI="https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu${PV}-EXE.zip -> ${P}.zip"

LICENSE="DisplayLink"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="systemd"

RESTRICT="strip mirror bindist"

BDEPEND="
	app-arch/unzip
"

RDEPEND="
	>=x11-drivers/evdi-1.14.0
	virtual/libusb:1
	x11-libs/libdrm
	systemd? ( sys-apps/systemd )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

QA_PREBUILT="
	usr/libexec/displaylink/DisplayLinkManager
"

# Suppress QA warnings for proprietary binary
# The binary has relative RPATH, executable stack, and other issues we cannot fix
QA_FLAGS_IGNORED="
	usr/libexec/displaylink/DisplayLinkManager
"

QA_EXECSTACK="
	usr/libexec/displaylink/DisplayLinkManager
"

QA_SONAME="
	usr/libexec/displaylink/DisplayLinkManager
"

# Suppress RPATH security warnings - we cannot modify proprietary binary
QA_TEXTRELS="
	usr/libexec/displaylink/DisplayLinkManager
"

src_unpack() {
	default

	cd "${WORKDIR}" || die

	# Find the .run self-extracting installer
	local run_file=$(find . -maxdepth 1 -name "displaylink-driver-*.run" -type f | head -n1)
	[[ -z "${run_file}" ]] && die "Could not find .run installer in ${WORKDIR}"

	chmod +x "${run_file}" || die

	# Extract the .run file without executing installer logic
	# Try --noexec first, fall back to manual extraction if it fails
	if ! sh "${run_file}" --noexec --target "${S}/extracted" 2>/dev/null; then
		einfo "Standard extraction failed, trying manual extraction..."
		mkdir -p "${S}/extracted" || die

		# Find the embedded tarball and extract it
		local marker=$(grep -axm1 '__EOF__' "${run_file}" | cut -d: -f1)
		[[ -z "${marker}" ]] && marker=$(grep -axm1 'exit 0' "${run_file}" | cut -d: -f1)
		[[ -z "${marker}" ]] && die "Could not find embedded archive marker"

		tail -n +$((marker + 1)) "${run_file}" | tar xz -C "${S}/extracted" || die
	fi

	S="${WORKDIR}/extracted"
}

src_prepare() {
	default

	# Note: We use our own systemd service file from ${FILESDIR}
	# The official installer script dynamically generates one, but we provide
	# a static FHS-compliant version instead
}

src_install() {
	# Determine architecture-specific binary directory
	local arch_dir
	case "${ARCH}" in
		amd64) arch_dir="x64-ubuntu-"* ;;
		arm64) arch_dir="aarch64-ubuntu-"* ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	# Find the actual directory (handle glob)
	local binary_dir=$(find . -maxdepth 1 -type d -name "${arch_dir}" | head -n1)
	[[ -z "${binary_dir}" ]] && die "Could not find binary directory matching ${arch_dir}"

	einfo "Using binary directory: ${binary_dir}"

	# Install main daemon binary
	exeinto /usr/libexec/displaylink
	doexe "${binary_dir}"/DisplayLinkManager || die "Failed to install DisplayLinkManager"

	# Install firmware files (architecture-independent)
	insinto /usr/libexec/displaylink
	doins *.spkg || die "Failed to install firmware files"

	# Install systemd service file
	if use systemd; then
		systemd_dounit "${FILESDIR}"/displaylink-driver.service
	fi

	# Install udev rules and helper script
	udev_dorules "${FILESDIR}"/99-displaylink.rules
	exeinto /usr/libexec/displaylink
	doexe "${FILESDIR}"/udev.sh

	# Documentation
	if [[ -f LICENSE ]]; then
		dodoc LICENSE
	fi

	if [[ -f README ]]; then
		dodoc README
	fi
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
