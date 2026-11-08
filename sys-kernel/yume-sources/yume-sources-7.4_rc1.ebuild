# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_P=linux-${PV/_/-}
# 7.4 builds the unchanged 7.3.0 J293 configuration through olddefconfig.
YUME_CONFIG=7.3.0

DESCRIPTION="Yume kernel sources with Gentoo and Apple Silicon hardware patches"
HOMEPAGE="https://github.com/melynx/nekochigura https://www.kernel.org/"
SRC_URI="https://git.kernel.org/torvalds/t/${MY_P}.tar.gz"
S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
SLOT="${PV}"
KEYWORDS="~amd64"
IUSE="apple"
REQUIRED_USE="apple? ( arm64 )"
# Source-tree test fixtures must retain their original binary contents.
RESTRICT="binchecks strip"

BDEPEND="app-arch/xz-utils"

src_prepare() {
	local patchdir=${WORKDIR}/yume-patches
	mkdir "${patchdir}" || die
	tar -xJf "${FILESDIR}/${PN}-${PVR}-patches.tar.xz" -C "${patchdir}" || die

	# Aurora rewrites shared mm, scheduler, USB and IOMMU code; other
	# machines keep upstream's.
	local series=( series )
	use apple && series+=( series-apple )
	local list patch
	for list in "${series[@]}"; do
		while IFS= read -r patch; do
			eapply --fuzz=0 "${patchdir}/patches/${patch}"
		done < "${patchdir}/patches/${list}"
	done
	eapply_user
	if use apple; then
		xz -dc "${FILESDIR}/yume-${YUME_CONFIG}-j293.config.xz" > "${T}/config-j293" || die
	fi
}

src_configure() { :; }
src_compile() { :; }

src_install() {
	# Keep the complete source separate from yume-kernel's module-build headers.
	local sourcedir=/usr/src/linux-${PV}-yume-sources
	dodir "${sourcedir}"
	cp -a . "${ED}${sourcedir}/" || die

	insinto /usr/share/yume-kernel/${PV}
	use apple && newins "${T}/config-j293" config-j293
	newins "${FILESDIR}/yume-${PVR}-provenance.json" source-provenance.json
}

pkg_postinst() {
	elog "Full Yume sources: /usr/src/linux-${PV}-yume-sources"
	elog "sys-kernel/yume-kernel builds and installs the configured kernel."
}
