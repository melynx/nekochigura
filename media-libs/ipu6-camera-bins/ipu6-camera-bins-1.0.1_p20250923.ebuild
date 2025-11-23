EAPI=8

DESCRIPTION="Binary libraries for Intel IPU6 camera HAL"
HOMEPAGE="https://github.com/intel/ipu6-camera-bins"

MY_PV=20250923_ov02e

SRC_URI="https://github.com/intel/ipu6-camera-bins/archive/refs/tags/${MY_PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="intel-ipu6-camera-bins"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip mirror bindist"

BDEPEND="
	app-admin/chrpath
"

S="${WORKDIR}/${PN}-${MY_PV}"

QA_PREBUILT="usr/lib*/lib*.so*"

src_prepare() {
	default

	# Strip RUNPATH/RPATH (e.g. /usr/lib) from prebuilt blobs
	local f
	for f in lib/*.so.* ; do
		# chrpath -l exits non-zero if there's no tag, so guard it
		if chrpath -l "${f}" &>/dev/null ; then
			chrpath -d "${f}" || die "chrpath -d failed for ${f}"
		fi
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
    elog "  Libraries: /usr/lib64/"
    elog "  Headers: /usr/include/"
    elog ""
    elog "Supported IPU versions: IPU6, IPU6EP, IPU6EPMTL"
    elog ""
    elog "Note: Firmware files are not included in this package."
    elog "IPU6 firmware is available in sys-kernel/linux-firmware."
    elog ""
    elog "This package a requirement for media-libs/ipu6-camera-hal to function properly."
}
