# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLAMA_CPP_BUILD="b9888"

inherit cmake go-module multiprocessing systemd

DESCRIPTION="Get up and running with Llama, Gemma, and other language models"
HOMEPAGE="https://ollama.com"
SRC_URI="
	https://github.com/ollama/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/gentoo-golang-dist/${PN}/releases/download/v${PV}/${P}-deps.tar.xz
	https://github.com/ggml-org/llama.cpp/archive/refs/tags/${LLAMA_CPP_BUILD}.tar.gz
		-> llama.cpp-${LLAMA_CPP_BUILD}.tar.gz
"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="cuda rocm vulkan"
RESTRICT="mirror"

GPU_DEPS="
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	rocm? (
		>=dev-util/hip-7.2:=
		<dev-util/hip-7.3
		>=sci-libs/hipBLAS-7.2:=
		<sci-libs/hipBLAS-7.3
		>=sci-libs/rocBLAS-7.2:=
		<sci-libs/rocBLAS-7.3
	)
	vulkan? ( media-libs/vulkan-loader )
"
DEPEND="${GPU_DEPS}"
BDEPEND="
	>=dev-lang/go-1.26
	vulkan? (
		dev-util/vulkan-headers
		media-libs/shaderc
	)
"
RDEPEND="
	${GPU_DEPS}
	>=acct-user/${PN}-4[cuda?,rocm?,vulkan?]
"

PATCHES=( "${FILESDIR}/${PN}-0001-respect-downstream-build-policy.patch" )

# go-module ignores flags for Go binaries by default. Ollama also builds native
# runners, so let Portage check every installed object.
QA_FLAGS_IGNORED=""

src_prepare() {
	cmake_src_prepare
	pushd "${WORKDIR}/llama.cpp-${LLAMA_CPP_BUILD}" >/dev/null || die
	eapply "${S}/llama/compat/001-llama-cpp-hooks.patch"
	eapply "${S}/llama/compat/models/003-llama-cpp-laguna.patch"
	popd >/dev/null || die
}

src_configure() {
	local -a backends=()
	local backend_string

	if use cuda; then
		if has_version ">=dev-util/nvidia-cuda-toolkit-13"; then
			backends+=( cuda_v13 )
		else
			backends+=( cuda_v12 )
		fi
	fi
	use rocm && backends+=( rocm_v7_2 )
	use vulkan && backends+=( vulkan )
	backend_string=$(IFS=";"; echo "${backends[*]}")

	local mycmakeargs=(
		-DFETCHCONTENT_SOURCE_DIR_LLAMA_CPP="${WORKDIR}/llama.cpp-${LLAMA_CPP_BUILD}"
		-DOLLAMA_BUILD_PARALLEL="$(makeopts_jobs)"
		-DOLLAMA_LIB_DIR="$(get_libdir)/ollama"
		-DOLLAMA_LLAMA_BACKENDS="${backend_string}"
		-DOLLAMA_VERSION="${PV}"
	)

	cmake_src_configure
}

src_test() {
	ego test -count=1 -benchtime=1x ./...
}

src_install() {
	cmake_src_install

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
