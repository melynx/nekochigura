# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd unpacker

MY_PN="${PN%-bin}"
MY_PV="${PV/_/-}"

DESCRIPTION="Run large language models locally (binary distribution)"
HOMEPAGE="https://ollama.com"
SRC_URI="
	amd64? (
		rocm? (
			https://github.com/ollama/${MY_PN}/releases/download/v${MY_PV}/${MY_PN}-linux-amd64-rocm.tar.zst
				-> ${P}-amd64-rocm.tar.zst
		)
		!rocm? (
			https://github.com/ollama/${MY_PN}/releases/download/v${MY_PV}/${MY_PN}-linux-amd64.tar.zst
				-> ${P}-amd64.tar.zst
		)
	)
	arm64? (
		https://github.com/ollama/${MY_PN}/releases/download/v${MY_PV}/${MY_PN}-linux-arm64.tar.zst
			-> ${P}-arm64.tar.zst
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda rocm"

RESTRICT="mirror strip"

BDEPEND="$(unpacker_src_uri_depends)"

RDEPEND="
	acct-group/${MY_PN}
	>=acct-user/${MY_PN}-3[cuda?]
	!sci-ml/ollama
"

QA_PREBUILT="usr/bin/ollama"

src_install() {
	dobin bin/ollama

	# Install bundled libraries
	if [[ -d lib/ollama ]]; then
		insinto /usr/$(get_libdir)/ollama
		doins -r lib/ollama/*
		# Make shared libraries executable
		find "${ED}"/usr/$(get_libdir)/ollama -name "*.so*" -exec chmod +x {} \; || die
	fi

	# Install systemd service
	systemd_newunit "${FILESDIR}/ollama.service" ollama.service

	# Install OpenRC init script
	newinitd "${FILESDIR}/ollama.init" ollama

	# Create log directory
	keepdir /var/log/ollama
	fowners ollama:ollama /var/log/ollama
}

pkg_postinst() {
	elog "To start ollama, run:"
	elog "  systemctl start ollama"
	elog "or"
	elog "  rc-service ollama start"
	elog ""
	elog "To use ollama, simply run:"
	elog "  ollama run llama3.2"
	elog ""
	if use cuda; then
		elog "For CUDA support, make sure your user is in the 'video' group:"
		elog "  usermod -aG video <username>"
	fi
}
