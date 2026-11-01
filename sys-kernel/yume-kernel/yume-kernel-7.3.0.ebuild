# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 18 )
LLVM_OPTIONAL=1
RUST_MIN_VER=1.91.0
RUST_MAX_VER=1.91.0
RUST_REQ_USE="rust-src,rustfmt"

inherit kernel-build llvm-r2 rust

CONFIG_VER=7.2.10-gentoo
GENTOO_CONFIG_P=gentoo-kernel-config-g19

DESCRIPTION="Yume distribution kernel with Gentoo and Apple Silicon support"
HOMEPAGE="https://github.com/melynx/nekochigura https://www.kernel.org/"
SRC_URI="
	!apple? (
		https://distfiles.gentoo.org/pub/proj/dist-kernel/config/fedora-kernel-config-${CONFIG_VER}.tar.xz
		https://gitweb.gentoo.org/proj/dist-kernel/gentoo-kernel-config.git/snapshot/${GENTOO_CONFIG_P}.tar.bz2
	)
"
S=${WORKDIR}/linux-${PV}-yume

KEYWORDS="~amd64 ~arm64"
IUSE="apple debug"
REQUIRED_USE="${LLVM_REQUIRED_USE} apple? ( arm64 )"

DEPEND="~sys-kernel/yume-sources-${PV}"
BDEPEND="
	>=dev-util/bindgen-0.73.2:0
	llvm-core/clang:18
	arm64? ( llvm-core/llvm:18[llvm_targets_AArch64] )
	amd64? ( llvm-core/llvm:18[llvm_targets_X86] )
	apple? (
		dev-util/pahole
		llvm-core/lld:18
	)
	!apple? ( debug? ( dev-util/pahole ) )
"
# Follow Gentoo: a newer virtual must also satisfy retained kernel versions.
PDEPEND=">=virtual/dist-kernel-${PV}"

pkg_setup() {
	if use apple; then
		llvm-r2_pkg_setup
	fi
	rust_pkg_setup
	kernel-build_pkg_setup
}

src_unpack() {
	default
	local source=${ESYSROOT}/usr/src/linux-${PV}-yume-sources
	[[ -d ${source} ]] || die "Install ~sys-kernel/yume-sources-${PV} first"
	mkdir "${S}" || die
	cp -a "${source}/." "${S}/" || die
}

src_prepare() {
	default
	local merge_configs=()
	if use apple; then
		cp "${ESYSROOT}/usr/share/yume-kernel/${PV}/config-j293" .config || die
	else
		case ${ARCH} in
			amd64)
				cp "${WORKDIR}/fedora-kernel-config-${CONFIG_VER}/kernel-x86_64-fedora.config" .config || die
				;;
			arm64)
				cp "${WORKDIR}/fedora-kernel-config-${CONFIG_VER}/kernel-aarch64-fedora.config" .config || die
				;;
			*) die "Unsupported architecture: ${ARCH}" ;;
		esac
		merge_configs+=(
			"${WORKDIR}/${GENTOO_CONFIG_P}/base.config"
			"${WORKDIR}/${GENTOO_CONFIG_P}/6.12+.config"
		)
		use debug || merge_configs+=( "${WORKDIR}/${GENTOO_CONFIG_P}/no-debug.config" )
		cat > "${T}/generic.config" <<-EOF || die
			CONFIG_LOCALVERSION="-yume"
		EOF
		if use arm64; then
			cat >> "${T}/generic.config" <<-EOF || die
				CONFIG_ARM64_4K_PAGES=y
				# CONFIG_ARCH_APPLE is not set
			EOF
		fi
		merge_configs+=( "${T}/generic.config" )
		use secureboot && merge_configs+=( "${WORKDIR}/${GENTOO_CONFIG_P}/secureboot.config" )
	fi
	if use arm64; then
		# The normal install hooks must receive an executable EFI image.
		cat > "${T}/efi.config" <<-EOF || die
			CONFIG_EFI_ZBOOT=y
		EOF
		merge_configs+=( "${T}/efi.config" )
	fi
	kernel-build_merge_configs "${merge_configs[@]}"
}

src_configure() {
	export KBUILD_BUILD_USER=yume KBUILD_BUILD_HOST=nekochigura
	local llvm_prefix=$(get_llvm_prefix -b)
	local rust_prefix=$(get_rust_prefix -b)
	export HOSTRUSTC=${rust_prefix}/bin/rustc
	export RUSTFMT=${rust_prefix}/bin/rustfmt
	export RUST_LIB_SRC=$(${RUSTC} --print sysroot)/lib/rustlib/src/rust/library
	export LIBCLANG_PATH=${llvm_prefix}/lib64
	export BINDGEN=${BROOT}/usr/bin/bindgen

	# Rust bindings need libclang even when the C compiler is GCC.
	if ! use apple; then
		kernel-build_src_configure
		return
	fi
	export LLVM_IAS=1

	# kernel-build records these selected tools in MAKEARGS for later phases.
	local -x CC=${llvm_prefix}/bin/clang LD=${llvm_prefix}/bin/ld.lld
	local -x AR=${llvm_prefix}/bin/llvm-ar NM=${llvm_prefix}/bin/llvm-nm
	local -x STRIP=${llvm_prefix}/bin/llvm-strip
	local -x OBJCOPY=${llvm_prefix}/bin/llvm-objcopy
	local -x OBJDUMP=${llvm_prefix}/bin/llvm-objdump
	local -x READELF=${llvm_prefix}/bin/llvm-readelf
	local -x BUILD_CC=${llvm_prefix}/bin/clang
	local -x BUILD_CXX=${llvm_prefix}/bin/clang++
	local -x BUILD_LD=${llvm_prefix}/bin/ld.lld
	local -x BUILD_AR=${llvm_prefix}/bin/llvm-ar

	kernel-build_src_configure
}

src_compile() {
	if ! use apple; then
		kernel-build_src_compile
		return
	fi

	# Only J293 is qualified by the initial Apple configuration.
	local image_target=$(dist-kernel_get_image_path)
	emake O="${WORKDIR}/build" "${MAKEARGS[@]}" \
		Image "${image_target##*/}" modules apple/t8103-j293.dtb
	# dtbs_install reads this inventory; retain exactly the built board.
	printf '%s\n' arch/arm64/boot/dts/apple/t8103-j293.dtb \
		> "${WORKDIR}/build/arch/arm64/boot/dts/dtbs-list" || die
}
