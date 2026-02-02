
EAPI=8

inherit autotools

DESCRIPTION="GStreamer plugin for Intel IPU6/IPU6EP/IPU6SE MIPI cameras"
HOMEPAGE="https://github.com/intel/icamerasrc"

MY_PV="20251226_1140_191_PTL_PV_IoT"
SRC_URI="https://github.com/intel/icamerasrc/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/icamerasrc-${MY_PV}"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+drm"

RDEPEND="
	>=media-libs/gstreamer-1.0.0:1.0
	>=media-libs/gst-plugins-base-1.0.0:1.0
	media-libs/ipu6-camera-hal
	media-libs/ipu6-camera-bins
	x11-libs/libdrm
	drm? (
		|| (
			>=media-libs/gstreamer-1.23
			=media-libs/gstreamer-1.22.6
		)
		media-libs/gst-plugins-bad:1.0
		media-libs/libva
	)
"

DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
	dev-build/autoconf
	dev-build/automake
	dev-build/libtool
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	export CHROME_SLIM_CAMHAL=ON

	local myeconfargs=(
		$(use_enable drm gstdrmformat)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die

	# GStreamer plugin cache will be regenerated
	rm -f "${ED}"/usr/lib*/gstreamer-1.0/libgsticamerasrc.a || die
}

pkg_postinst() {
	elog "This package provides the 'icamerasrc' GStreamer plugin for Intel"
	elog "IPU6/IPU6EP/IPU6SE camera support on Tiger Lake, Alder Lake, and"
	elog "Jasper Lake platforms."
	elog ""
	elog "You also need the following packages installed:"
	elog "  - media-libs/ipu6-camera-bins (IPU firmware and libraries)"
	elog "  - media-libs/ipu6-camera-hal (camera HAL)"
	elog "  - media-video/ipu6-drivers (IPU6 PSYS Driver)"
	elog ""
	elog "Example usage:"
	elog "  gst-launch-1.0 icamerasrc buffer-count=7 ! video/x-raw,format=NV12,width=1280,height=720 ! videoconvert ! ximagesink"
	elog ""
	if use drm; then
		elog "DRM format support is enabled for DMA buffer sharing."
	else
		elog "To enable DRM format support for DMA buffers, enable the 'drm' USE flag."
	fi
}

pkg_postrm() {
	# Only clean up if no other version of this package remains installed
	has_version "${CATEGORY}/${PN}" && return

	# Clean up any leftover files in case make uninstall didn't remove everything
	local files=(
		"${EROOT}"/usr/$(get_libdir)/gstreamer-1.0/libgsticamerasrc.so*
		"${EROOT}"/usr/$(get_libdir)/libgsticamerainterface-1.0.so*
		"${EROOT}"/usr/$(get_libdir)/pkgconfig/libgsticamerasrc.pc
		"${EROOT}"/usr/include/gstreamer-1.0/gst/icamera
	)

	local f
	for f in "${files[@]}"; do
		if [[ -e "${f}" ]]; then
			einfo "Removing leftover file: ${f}"
			rm -rf "${f}" || ewarn "Failed to remove ${f}"
		fi
	done
}
