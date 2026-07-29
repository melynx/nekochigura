# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_BUILD="21919.ede283a88e3"
MY_ARCHIVE="openvino_toolkit_ubuntu24_${PV}.${MY_BUILD}_x86_64"

DESCRIPTION="Prebuilt OpenVINO C and C++ runtime with Intel CPU, GPU, and NPU plugins"
HOMEPAGE="https://docs.openvino.ai/"
SRC_URI="https://storage.openvinotoolkit.org/repositories/openvino/packages/${PV}/linux/${MY_ARCHIVE}.tgz
	-> ${P}-amd64.tgz"
S="${WORKDIR}/${MY_ARCHIVE}"

LICENSE="Apache-2.0 intel-openvino"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"

RESTRICT="mirror strip"

RDEPEND="
	app-arch/zstd
	dev-libs/intel-compute-runtime
	>=sys-devel/gcc-12:*
	>=sys-libs/glibc-2.38
	>=virtual/opencl-3
"

QA_PREBUILT="
	opt/openvino/${PV}/runtime/3rdparty/tbb/lib/lib*.so*
	opt/openvino/${PV}/runtime/lib/intel64/lib*.so*
"

OPENVINO_ROOT="/opt/openvino/${PV}"

src_install() {
	dodir "${OPENVINO_ROOT}"
	cp -a runtime "${ED}${OPENVINO_ROOT}/" || die

	insinto "${OPENVINO_ROOT}/docs"
	doins -r docs/licensing

	# Keep one stable path for the loader configuration and CMake wrapper.
	dosym "${PV}" /opt/openvino/latest

	doenvd "${FILESDIR}/90openvino"

	insinto "/usr/$(get_libdir)/cmake/OpenVINO"
	doins \
		"${FILESDIR}/OpenVINOConfig.cmake" \
		"${FILESDIR}/OpenVINOConfig-version.cmake"
}

pkg_postinst() {
	elog "OpenVINO ${PV} is installed under ${OPENVINO_ROOT}."
	elog "CPU and Intel GPU runtime plugins are ready for device discovery."
	elog "The NPU plugin and compiler are included. NPU access also needs a"
	elog "supported kernel driver and firmware, which this package does not install."
}
