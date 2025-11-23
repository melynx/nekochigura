EAPI=8

inherit cmake

DESCRIPTION="Intel IPU6 Camera Hardware Abstraction Layer"
HOMEPAGE="https://github.com/intel/ipu6-camera-hal"
MY_PV="20250923_ov02e"
SRC_URI="https://github.com/intel/ipu6-camera-hal/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+adapter live-tuning +plugin +pglite-pipe +ipu6 +ipu6ep +ipu6epmtl"
REQUIRED_USE="
	|| ( ipu6 ipu6ep ipu6epmtl )
	adapter? ( plugin )
"

BDEPEND="
	virtual/pkgconfig
"
DEPEND="
	dev-libs/expat
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	>=x11-libs/libdrm-2.4.114
	media-libs/ipu6-camera-bins
"
RDEPEND="${DEPEND}"

DOCS=( README.md SECURITY.md )

src_configure() {
	local ipu_targets=()
	use ipu6 && ipu_targets+=( ipu6 )
	use ipu6ep && ipu_targets+=( ipu6ep )
	use ipu6epmtl && ipu_targets+=( ipu6epmtl )

	local ipu_versions
	ipu_versions=$(printf '%s;' "${ipu_targets[@]}")
	ipu_versions=${ipu_versions%;}

	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DCMAKE_INSTALL_SYSCONFDIR="/etc"
		-DBUILD_CAMHAL_ADAPTOR="$(usex adapter ON OFF)"
		-DBUILD_CAMHAL_PLUGIN="$(usex plugin ON OFF)"
		-DUSE_PG_LITE_PIPE="$(usex pglite-pipe ON OFF)"
		-DSUPPORT_LIVE_TUNING="$(usex live-tuning ON OFF)"
		-DIPU_VERSIONS="${ipu_versions}"
	)

	cmake_src_configure
}

#pkg_prerm() {
#	local libdir="${EROOT}/usr/$(get_libdir)"
#
#	# Remove installed libraries
#	einfo "Removing libcamhal libraries"
#	rm -f "${libdir}"/libcamhal.so* || die
#	rm -f "${libdir}"/libcamhal_static.a || die
#
#	# Remove IPU-specific plugin libraries
#	local ipu_variant
#	for ipu_variant in ipu6 ipu6ep ipu6epmtl; do
#		rm -f "${libdir}"/${ipu_variant}.so* || die
#		rm -f "${libdir}"/${ipu_variant}_static.a || die
#	done
#
#	# Remove plugin directory if it exists
#	if [[ -d "${libdir}/libcamhal" ]]; then
#		einfo "Removing plugin directory: ${libdir}/libcamhal"
#		rm -rf "${libdir}/libcamhal" || die
#	fi
#
#	# Remove pkgconfig file
#	rm -f "${libdir}/pkgconfig/libcamhal.pc" || die
#
#	# Remove headers
#	if [[ -d "${EROOT}/usr/include/libcamhal" ]]; then
#		einfo "Removing headers: /usr/include/libcamhal"
#		rm -rf "${EROOT}/usr/include/libcamhal" || die
#	fi
#
#	# Remove configuration files
#	for ipu_variant in ipu6 ipu6ep ipu6epmtl; do
#		if [[ -d "${EROOT}/etc/camera/${ipu_variant}" ]]; then
#			einfo "Removing configuration: /etc/camera/${ipu_variant}"
#			rm -rf "${EROOT}/etc/camera/${ipu_variant}" || die
#		fi
#	done
#}

pkg_postinst() {
    elog "Intel IPU6 Camera HAL has been installed."
    elog ""
    elog "This provides userspace camera processing for Intel Tiger Lake,"
    elog "Alder Lake, Raptor Lake, and Meteor Lake platforms."
    elog ""
	elog "Build configuration:"
    if use plugin && use adapter; then
        elog "  Mode: Plugin with adaptor (runtime hardware detection)"
        elog "  Libraries: /usr/$(get_libdir)/libcamhal/plugins/"
    else
        elog "  Mode: Standard shared library"
        elog "  Library: /usr/$(get_libdir)/libcamhal.so"
    fi

    local enabled_ipus=()
    use ipu6 && enabled_ipus+=( "IPU6" )
    use ipu6ep && enabled_ipus+=( "IPU6EP" )
    use ipu6epmtl && enabled_ipus+=( "IPU6EPMTL" )
    elog "  Supported IPU versions: ${enabled_ipus[*]}"

    use live-tuning && elog "  Live tuning: Enabled"
}
