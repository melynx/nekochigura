# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Aurora's reference image hashes hold only for clang 22; other LLVM
# versions change the image bytes.
LLVM_COMPAT=( 22 )

inherit llvm-r2 meson

# aurora-silicon/avd-fw, the commit alarm-aurora pins (0.1.aurora3-1)
COMMIT="6062e8516c0a751bc8e50f5d604a17395923189f"

DESCRIPTION="Open replacement firmware for the Apple Video Decoder (Aurora Silicon)"
HOMEPAGE="https://github.com/aurora-silicon/avd-fw"
SRC_URI="https://github.com/aurora-silicon/avd-fw/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/avd-fw-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"
IUSE="test"
RESTRICT="!test? ( test ) strip"

BDEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/lld:${LLVM_SLOT}
		llvm-core/llvm:${LLVM_SLOT}[llvm_targets_ARM]
	')
"

# Cortex-M3 firmware images, not host binaries.
QA_PREBUILT="usr/lib/firmware/apple/*"

src_configure() {
	# The cross file selects clang for a bare-metal Cortex-M3 target.
	# The eclass's buildtype=plain would drop upstream's -O2 default, and the
	# reference images are built with it.
	local emesonargs=(
		--cross-file "${S}/llvm.ini"
		--libdir=lib
		-Doptimization=2
		-Ddebug=false
	)
	meson_src_configure
}

src_test() {
	# Aurora's clang 22 build produces exactly these images (alarm-aurora PKGBUILD).
	cd "${BUILD_DIR}" || die
	sha256sum -c "${FILESDIR}/${P}-clang22.sha256" || die "firmware images differ from Aurora's"
}

src_install() {
	meson_src_install
	chmod 0644 "${ED}"/usr/lib/firmware/apple/*.bin || die
}
