# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_P=linux-${PV%.0}

DESCRIPTION="Yume kernel sources with Gentoo and Apple Silicon hardware patches"
HOMEPAGE="https://github.com/melynx/nekochigura https://www.kernel.org/"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${MY_P}.tar.xz"
S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
SLOT="${PV}"
KEYWORDS="~amd64 ~arm64"
# Source-tree test fixtures must retain their original binary contents.
RESTRICT="binchecks strip"

BDEPEND="app-arch/xz-utils"

src_prepare() {
	local patchdir=${WORKDIR}/yume-patches
	mkdir "${patchdir}" || die
	tar -xJf "${FILESDIR}/${P}-patches.tar.xz" -C "${patchdir}" || die

	local patch
	while IFS= read -r patch; do
		eapply --fuzz=0 "${patchdir}/patches/${patch}"
	done < "${patchdir}/patches/series"
	eapply_user
	xz -dc "${FILESDIR}/yume-${PV}-j293.config.xz" > "${T}/config-j293" || die
}

src_configure() { :; }
src_compile() { :; }

src_install() {
	# Keep the complete source separate from yume-kernel's module-build headers.
	local sourcedir=/usr/src/linux-${PV}-yume-sources
	dodir "${sourcedir}"
	cp -a . "${ED}${sourcedir}/" || die

	insinto /usr/share/yume-kernel/${PV}
	newins "${T}/config-j293" config-j293
	newins "${FILESDIR}/yume-${PV}-provenance.json" source-provenance.json
}

pkg_postinst() {
	elog "Full Yume sources: /usr/src/linux-${PV}-yume-sources"
	elog "sys-kernel/yume-kernel builds and installs the configured kernel."
}
