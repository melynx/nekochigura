# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

MY_BUILD="20260722-29947505341"
MY_ARCHIVE="linux-npu-driver-v${PV}.${MY_BUILD}-ubuntu2404"
MY_DEB="intel-level-zero-npu_${PV}.${MY_BUILD}~ubuntu24.04_amd64.deb"

DESCRIPTION="Prebuilt Intel Level Zero user-mode driver for NPU hardware"
HOMEPAGE="https://github.com/intel/linux-npu-driver"
SRC_URI="https://github.com/intel/linux-npu-driver/releases/download/v${PV}/${MY_ARCHIVE}.tar.gz
	-> ${P}-ubuntu2404.tar.gz"
S="${WORKDIR}"

LICENSE="Apache-2.0 MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"

RESTRICT="strip"

RDEPEND="
	>=dev-libs/level-zero-1.28.2
	>=sys-devel/gcc-13:*
	>=sys-libs/glibc-2.38
"

QA_PREBUILT="usr/lib64/libze_intel_npu.so.${PV}"

src_unpack() {
	default
	unpacker "${WORKDIR}/${MY_DEB}"
}

src_install() {
	local deb_libdir="usr/lib/x86_64-linux-gnu"

	dolib.so "${deb_libdir}/libze_intel_npu.so.${PV}"
	dosym "libze_intel_npu.so.${PV}" "/usr/$(get_libdir)/libze_intel_npu.so.1"
	dosym "libze_intel_npu.so.1" "/usr/$(get_libdir)/libze_intel_npu.so"
}

pkg_postinst() {
	elog "The Intel Level Zero NPU user-mode driver is installed."
	elog "NPU access also requires the intel_vpu kernel driver and matching firmware."
}
