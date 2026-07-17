# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"

DESCRIPTION="Provision self-hosted cloud development environments"
HOMEPAGE="https://github.com/coder/coder"
SRC_URI="
	amd64? (
		https://github.com/coder/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/coder/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="AGPL-3 Coder-Enterprise"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/coder"

src_install() {
	dobin coder
	dodoc README.md LICENSE.enterprise
}

pkg_postinst() {
	elog "To get started with Coder, run:"
	elog ""
	elog "  coder server  # Start the Coder server"
	elog "  coder login   # Log in to a Coder deployment"
	elog ""
	elog "For more information visit https://coder.com/docs"
}
