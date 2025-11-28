EAPI=8

inherit linux-mod-r1

DESCRIPTION="Intel IPU6 kernel drivers for MIPI cameras"
HOMEPAGE="https://github.com/intel/ipu6-drivers"

MY_PV=20251104_0740_359
DKMS_VER="${PV%_*}"

SRC_URI="https://github.com/intel/ipu6-drivers/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+dkms"

# Dependencies for runtime
RDEPEND="
	dkms? ( sys-kernel/dkms )
"

# Dependencies for building
DEPEND="
	virtual/linux-sources
	>=sys-kernel/linux-headers-6.17
	${RDEPEND}
"

BDEPEND="
	virtual/pkgconfig
"

# These drivers work on Intel platforms with IPU6
# Tiger Lake, Alder Lake, Raptor Lake, and Meteor Lake
RESTRICT="test"

MODULES=(
	    intel-ipu6-psys
        hm11b1
        gc5035
        ov01a1s
        ov02c10
        ov02e10
        ov05c10
        hm2170
        hm2172
        imx471
        s5k3j1
)

pkg_setup() {
	if use dkms; then
		# For DKMS installation, we don't need kernel sources at build time
		return
	fi

	# For manual module building, set up kernel build environment
	linux-mod-r1_pkg_setup

	# Check kernel configuration requirements
	local CONFIG_CHECK="
		~VIDEO_V4L2_I2C
		~MEDIA_CAMERA_SUPPORT
		~VIDEO_DEV
		~INTEL_SKL_INT3472
	"
		#~VIDEO_V4L2
		#~V4L_PLATFORM_DRIVERS

	# Check minimum kernel version - IPU6 drivers require at least 6.17
	linux_config_exists
	local kver=$(linux_chkconfig_string)
	if kernel_is lt 6 17; then
		die "IPU6 drivers require kernel version 6.17 or later. Current: ${kver}"
	fi

	local ERROR_VIDEO_V4L2="IPU6 drivers require Video4Linux2 support"
	local ERROR_VIDEO_V4L2_I2C="IPU6 drivers require Video4Linux2 I2C support"
	local ERROR_MEDIA_CAMERA_SUPPORT="IPU6 drivers require camera support"
	local ERROR_V4L_PLATFORM_DRIVERS="IPU6 drivers require V4L platform drivers"
	local ERROR_VIDEO_DEV="IPU6 drivers require video device support"
	local ERROR_INTEL_SKL_INT3472="IPU6 drivers require Intel Skylake INT3472 support"

	check_extra_config
}

src_prepare() {
	default

	# Apply patches for out-of-tree builds

	# For kernel >= 6.10, apply PSYS patch for out-of-tree builds
	if kernel_is ge 6 10 0 && ! use dkms; then
		einfo "Applying IPU6 PSYS patch for out-of-tree build on kernel ${kver}"
		if [[ -f "${S}/patches/0001-v6.10-IPU6-headers-used-by-PSYS.patch" ]]; then
			eapply "${S}/patches/0001-v6.10-IPU6-headers-used-by-PSYS.patch"
		else
			die "Required PSYS patch not found for kernel ${kver}"
		fi
	fi

	# The driver has built-in version detection logic in Makefile and dkms.conf
	# DKMS will handle patch application automatically
}

src_configure() {
	if use dkms; then
		# DKMS will handle configuration
		return
	fi

	# Only set EXTERNAL_BUILD - the Makefile handles all other CONFIG variables
	# automatically based on kernel version detection
	export EXTERNAL_BUILD=1
}

src_compile() {
	if use dkms; then
		# DKMS will handle compilation
		return
	fi

	# Set up module build configuration
	local modlist=(
		intel-ipu6-psys=updates::drivers/media/pci/intel/ipu6/psys
		hm11b1=updates::drivers/media/i2c
		gc5035=updates::drivers/media/i2c
		ov01a1s=updates::drivers/media/i2c
		ov02c10=updates::drivers/media/i2c
		ov02e10=updates::drivers/media/i2c
		ov05c10=updates::drivers/media/i2c
		hm2170=updates::drivers/media/i2c
		hm2172=updates::drivers/media/i2c
		imx471=updates::drivers/media/i2c
		s5k3j1=updates::drivers/media/i2c
	)

	local modargs=(
		KERNEL_SRC="${KV_DIR}"
		KERNELRELEASE="${KV_FULL}"
	)

	# Build kernel modules
	linux-mod-r1_src_compile
}

src_install() {
	if use dkms; then
		return
	else
		# Manual module installation
		linux-mod-r1_src_install

	#	# Install modules to updates directory like DKMS does
	#	emake INSTALL_MOD_DIR=updates INSTALL_MOD_PATH="${ED}" modules_install \
	#		KERNEL_SRC="${KV_DIR}" KERNELRELEASE="${KV_FULL}"
	fi

	# Install documentation
	einstalldocs
	dodoc README.md SECURITY.md
}

pkg_preinst() {
	if use dkms; then
		# Add the source directory to DKMS and auto-install
		if [[ -d "/var/lib/dkms/${PN}/${DKMS_VER}" ]]; then
			einfo "DKMS entry exists..."
		else
			einfo "Adding IPU6 drivers to DKMS..."
			dkms add "${S}" || die "Failed to add DKMS module"
		fi

		einfo "Building and installing IPU6 drivers via DKMS..."
		env -u ARCH dkms autoinstall "${PN}/${DKMS_VER}" || die "Failed to autoinstall DKMS module"
	else
		default
	fi
}

pkg_postinst() {
	if use dkms; then
		elog "IPU6 drivers have been installed via DKMS."
		elog "The modules will be automatically built and installed for each kernel."
		elog "Use 'dkms status' to check the status of the modules."
		elog ""
		elog "To manually manage:"
		elog "  dkms build ${PN}/${DKMS_VER}"
		elog "  dkms install ${PN}/${DKMS_VER}"
		elog "  dkms uninstall ${PN}/${DKMS_VER}"
	else
		linux-mod-r1_pkg_postinst

		elog "IPU6 drivers have been compiled and installed for kernel ${KV_FULL}"
		elog "You may need to run 'depmod -a' and reload the modules."
	fi

	elog ""
	elog "These drivers support Intel IPU6 on:"
	elog "  - Tiger Lake platforms"
	elog "  - Alder Lake platforms"
	elog "  - Raptor Lake platforms"
	elog "  - Meteor Lake platforms"
	elog "  (Requires kernel version 6.17 or later)"
	elog ""
	elog "Additional components needed for full camera functionality:"
	elog "  - media-libs/ipu6-camera-bins (firmware and libraries)"
	elog "  - media-libs/ipu6-camera-hal (userspace HAL)"
	elog "  - icamerasrc (GStreamer plugin)"
}

pkg_prerm() {
    # If REPLACED_BY_VERSION is non-empty, this pkg is being replaced
    # (upgrade or reinstall). Don't nuke the state in that case.
    if [[ -n ${REPLACED_BY_VERSION} ]]; then
        einfo "Skipping cleanup for ${PN}-${PV} (replaced by ${REPLACED_BY_VERSION})"
        return
    fi

	if use dkms; then
		einfo "Removing IPU6 drivers from DKMS..."
		dkms uninstall "${PN}/${DKMS_VER}" --all 2>/dev/null || true
		dkms remove "${PN}/${DKMS_VER}" --all || die "Failed to remove DKMS module"
	else
		# Remove module files manually if they exist
        local kernel_version=$(uname -r)
        local mod_path="/lib/modules/${kernel_version}/updates"

		einfo "Cleaning up IPU6 Drivers..."

        # if ! [[ -d "${mod_path}" ]]; then
        # fi

		! [[ -d "${mod_path}" ]] || die "${mod_path} not a directory..."

        einfo "Cleaning up module files in ${mod_path}..."

		for mod in "${MODULES[@]}"; do
			if lsmod | grep -q "^${mod}"; then
				einfo "Unloading module: ${mod}"
                rmmod "${mod}" 2>/dev/null || ewarn "Failed to unload ${mod} - may be in use"
            fi

			local mod_file="${mod_path}/${mod}.ko"

			if [[ -f "${mod_file}" ]]; then
            	einfo "Removing ${mod_file}..."
            	rm -f "${mod_file}" 2>/dev/null || true
			fi
		done

        # Update module dependencies
        einfo "Updating module dependencies..."
        depmod -a 2>/dev/null || ewarn "Failed to update module dependencies"

	fi
}
