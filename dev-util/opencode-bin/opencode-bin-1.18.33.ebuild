# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"

DESCRIPTION="The open source AI coding agent"
HOMEPAGE="https://github.com/anomalyco/opencode"
SRC_URI="
	amd64? (
		https://github.com/anomalyco/${MY_PN}/releases/download/v${PV}/opencode-linux-x64-baseline.tar.gz
			-> ${P}-x64-baseline.tar.gz
	)
	arm64? (
		https://github.com/anomalyco/${MY_PN}/releases/download/v${PV}/opencode-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="sys-apps/ripgrep"

QA_PREBUILT="usr/bin/opencode"

src_install() {
	dobin opencode
}

pkg_postinst() {
	elog "                        ▄     "
	elog "█▀▀█ █▀▀█ █▀▀█ █▀▀▄ █▀▀▀ █▀▀█ █▀▀█ █▀▀█"
	elog "█░░█ █░░█ █▀▀▀ █░░█ █░░░ █░░█ █░░█ █▀▀▀"
	elog "▀▀▀▀ █▀▀▀ ▀▀▀▀ ▀  ▀ █▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀"
	elog ""
	elog ""
	elog "OpenCode includes free models, to start:"
	elog ""
	elog "cd <project>  # Open directory"
	elog "opencode      # Run command"
	elog ""
	elog "For more information visit https://opencode.ai/docs"
}
