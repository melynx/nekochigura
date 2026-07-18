# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Binary libraries for Intel IPU6 camera HAL"
HOMEPAGE="https://github.com/intel/ipu6-camera-bins"

MY_PV=20260629_2

SRC_URI="https://github.com/intel/ipu6-camera-bins/archive/refs/tags/${MY_PV}.tar.gz
	-> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="intel-ipu6-camera-bins"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"

RESTRICT="strip mirror bindist"

BDEPEND="dev-util/patchelf"
RDEPEND="
	dev-libs/expat
	>=sys-devel/gcc-13.2:*
	>=sys-libs/glibc-2.38
	virtual/zlib:0/1
"

QA_PREBUILT="
	usr/lib*/lib*.so*
	usr/lib*/*.a
"

src_prepare() {
	default

	# Upstream pkg-config files hardcode /usr/lib.
	sed -i -e "s|^libdir=.*|libdir=\${exec_prefix}/$(get_libdir)|" \
		lib/pkgconfig/*.pc || die

	# Remove unsafe or invalid upstream library search paths.
	local f
	for f in lib/*.so.*; do
		patchelf --remove-rpath "${f}" || die
	done
}

src_install() {
	# Headers
	insinto /usr/include
	doins -r include/* || die

	# pkg-config files
	insinto /usr/$(get_libdir)/pkgconfig
	doins lib/pkgconfig/*.pc || die

	# Shared libraries (.so.N)
	dolib.so lib/lib*.so.* || die

	# Static libraries (.a)
	dolib.a lib/*.a || die

	# Create unversioned .so symlinks for the linker
	local lib base
	for lib in lib/lib*.so.* ; do
		lib=${lib##*/}          # strip leading "lib/"
		base=${lib%%.so.*}      # libfoo-ipu6epmtl
		dosym "${lib}" "/usr/$(get_libdir)/${base}.so" || die
	done

	einstalldocs
}

pkg_postinst() {
	elog "Intel IPU6 Camera Binary Libraries have been installed."
	elog "This provides precompiled libraries and header files for Intel"
	elog "Tiger Lake, Alder Lake, Raptor Lake, and Meteor Lake platforms."
	elog ""
	elog "Installation paths:"
	elog "  Libraries: /usr/$(get_libdir)/"
	elog "  Headers: /usr/include/"
	elog ""
	elog "Supported IPU versions: IPU6, IPU6EP, IPU6EPMTL"
	elog ""
	elog "Note: Firmware files are not included in this package."
	elog "IPU6 firmware is available in sys-kernel/linux-firmware."
	elog ""
	elog "This package is required by media-libs/ipu6-camera-hal."
}
