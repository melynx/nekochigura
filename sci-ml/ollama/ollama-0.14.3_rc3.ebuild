# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake go-module systemd

MY_PV="${PV/_/-}"

DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other language models"
HOMEPAGE="https://ollama.com"
SRC_URI="
	https://github.com/ollama/${PN}/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/gentoo-golang-dist/${PN}/releases/download/v${MY_PV}/${PN}-${MY_PV}-deps.tar.xz -> ${P}-deps.tar.xz
"

S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda rocm vulkan"

RESTRICT="mirror test"

DEPEND="
	>=dev-lang/go-1.23.4
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
	)
	rocm? (
		dev-util/hip:=
	)
"
BDEPEND="
	vulkan? (
		dev-util/vulkan-headers
		media-libs/shaderc
	)
"
RDEPEND="
	acct-group/${PN}
	>=acct-user/${PN}-3[cuda?]
"

PATCHES=(
	"${FILESDIR}/${PN}-9999-use-GNUInstallDirs.patch"
)

src_prepare() {
	cmake_src_prepare

	# Disable ccache
	sed -i 's/find_program(CCACHE_FOUND ccache)/set(CCACHE_FOUND "")/' llama/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DBUILD_SHARED_LIBS=OFF
	)

	if use cuda; then
		mycmakeargs+=(
			-DGGML_CUDA=ON
		)
	fi

	if use rocm; then
		mycmakeargs+=(
			-DGGML_HIPBLAS=ON
		)
	fi

	if use vulkan; then
		mycmakeargs+=(
			-DGGML_VULKAN=ON
		)
	fi

	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	# Build the Go binary
	ego build -trimpath -o ollama .
}

src_install() {
	dobin ollama

	cmake_src_install

	# Install systemd service
	systemd_dounit "${FILESDIR}/ollama.service"

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
