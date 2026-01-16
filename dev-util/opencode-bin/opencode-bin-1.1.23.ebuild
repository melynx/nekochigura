# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"

DESCRIPTION="The open source AI coding agent"
HOMEPAGE="https://github.com/anomalyco/opencode"
SRC_URI="
	amd64? (
		https://github.com/anomalyco/${MY_PN}/releases/download/v${PV}/opencode-linux-x64.tar.gz
			-> ${P}-x64.tar.gz
		https://github.com/anomalyco/${MY_PN}/releases/download/v${PV}/opencode-linux-x64-baseline.tar.gz
			-> ${P}-x64-baseline.tar.gz
	)
	arm64? (
		https://github.com/anomalyco/${MY_PN}/releases/download/v${PV}/opencode-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="sys-apps/ripgrep"

QA_PREBUILT="usr/bin/opencode"

src_unpack() {
	# Extract the appropriate tarball based on architecture
	if use amd64; then
		# Check for AVX2 support
		if grep -q avx2 /proc/cpuinfo 2>/dev/null; then
			unpack "${P}-x64.tar.gz"
		else
			unpack "${P}-x64-baseline.tar.gz"
		fi
	elif use arm64; then
		unpack "${P}-arm64.tar.gz"
	fi
}

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
