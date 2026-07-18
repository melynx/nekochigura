# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Intel IPU6 Camera Hardware Abstraction Layer"
HOMEPAGE="https://github.com/intel/ipu6-camera-hal"
MY_PV="20260629_2"
SRC_URI="https://github.com/intel/ipu6-camera-hal/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+adapter +plugin +ipu6 +ipu6ep +ipu6epmtl"
REQUIRED_USE="
	|| ( ipu6 ipu6ep ipu6epmtl )
	adapter? ( plugin )
	plugin? ( adapter )
	!plugin? ( ^^ ( ipu6 ipu6ep ipu6epmtl ) )
"

BDEPEND="
	virtual/pkgconfig
"
DEPEND="
	dev-libs/expat
	=media-libs/ipu6-camera-bins-1.0.1_p20260629*
	>=x11-libs/libdrm-2.4.114
"
RDEPEND="${DEPEND}"

DOCS=( README.md SECURITY.md )
PATCHES=( "${FILESDIR}"/${PN}-1.0.1-no-werror.patch )

src_configure() {
	local ipu_targets=()
	use ipu6 && ipu_targets+=( ipu6 )
	use ipu6ep && ipu_targets+=( ipu6ep )
	use ipu6epmtl && ipu_targets+=( ipu6epmtl )

	local ipu_versions
	ipu_versions=$(printf '%s;' "${ipu_targets[@]}")
	ipu_versions=${ipu_versions%;}

	local mycmakeargs=(
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DCMAKE_INSTALL_SYSCONFDIR="/etc"
		-DBUILD_CAMHAL_ADAPTOR="$(usex adapter ON OFF)"
		-DBUILD_CAMHAL_PLUGIN="$(usex plugin ON OFF)"
		-DUSE_PG_LITE_PIPE=ON
		-DSUPPORT_LIVE_TUNING=OFF
		-DIPU_VERSIONS="${ipu_versions}"
	)

	cmake_src_configure
}

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
}
