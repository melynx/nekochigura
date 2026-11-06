# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd unpacker

MY_PN="${PN%-bin}"

DESCRIPTION="Run large language models locally (official binary distribution)"
HOMEPAGE="https://ollama.com"
SRC_URI="
	https://github.com/ollama/${MY_PN}/releases/download/v${PV}/${MY_PN}-linux-amd64.tar.zst
		-> ${P}-amd64.tar.zst
	rocm? (
		https://github.com/ollama/${MY_PN}/releases/download/v${PV}/${MY_PN}-linux-amd64-rocm.tar.zst
			-> ${P}-amd64-rocm.tar.zst
	)
"
S="${WORKDIR}"

LICENSE="
	Apache-2.0 BSD BSD-2 GPL-3+ ISC MIT gcc-runtime-library-exception-3.1
	cuda? ( NVIDIA-CUDA )
"
SLOT="0"
KEYWORDS="amd64"
IUSE="cuda rocm vulkan"

RESTRICT="
	cuda? ( bindist )
	mirror strip
"

BDEPEND="
	$(unpacker_src_uri_depends)
	dev-util/patchelf
"
RDEPEND="
	>=acct-user/${MY_PN}-4[cuda?,rocm?,vulkan?]
	vulkan? ( media-libs/vulkan-loader )
	!sci-ml/${MY_PN}
"

QA_PREBUILT="
	usr/bin/ollama
	usr/lib*/ollama/*
	usr/lib*/ollama/*/*
"

src_prepare() {
	default

	local library
	for library in lib/ollama/libggml-cpu-*.so; do
		patchelf --set-rpath '$ORIGIN' "${library}" || die
	done

	if ! use cuda; then
		rm -r lib/ollama/cuda_v* || die
	fi
	if ! use vulkan; then
		rm -r lib/ollama/vulkan || die
	fi
}

src_install() {
	dobin bin/ollama

	insinto /usr/$(get_libdir)/ollama
	doins -r lib/ollama/*
	fperms 0755 \
		/usr/$(get_libdir)/ollama/llama-quantize \
		/usr/$(get_libdir)/ollama/llama-server
	find "${ED}"/usr/$(get_libdir)/ollama -type f -name '*.so*' \
		-exec chmod 0755 {} + || die

	systemd_dounit "${FILESDIR}/ollama.service"
	newinitd "${FILESDIR}/ollama.init" ollama
	newconfd "${FILESDIR}/ollama.confd" ollama

	keepdir /var/log/ollama
	fowners ollama:ollama /var/log/ollama
	fperms 0750 /var/log/ollama
}

pkg_postinst() {
	elog "To start Ollama, run:"
	elog "  systemctl start ollama"
	elog "or"
	elog "  rc-service ollama start"
	elog ""
	elog "To use Ollama, run:"
	elog "  ollama run llama3.2"
	if use cuda || use rocm || use vulkan; then
		elog ""
		elog "Log out and back in after installation so the Ollama service"
		elog "account receives its GPU group membership."
	fi
}
