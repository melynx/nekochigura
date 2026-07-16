# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-env go-module

VENDOR_COMMIT="43ec2e46b358b709ed53d4e07dc9870f7f02ca5e"

DESCRIPTION="Wayland clipboard manager with support for multimedia"
HOMEPAGE="https://github.com/sentriz/cliphist"
SRC_URI="
	https://github.com/sentriz/cliphist/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://raw.githubusercontent.com/melynx/nekochigura-dependencies/${VENDOR_COMMIT}/app-misc/${PN}/${P}-vendor.tar.xz
"

LICENSE="GPL-3 MIT BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	gui-apps/wl-clipboard
	x11-misc/xdg-utils
"
DEPEND="${RDEPEND}"
# golang.org/x/image-0.44.0 requires Go 1.25.
BDEPEND=">=dev-lang/go-1.25.0"

PATCHES=(
	# Backport upstream commit 25cc3e4: create clipboard databases with mode
	# 0600 rather than 0644.
	"${FILESDIR}/${PN}-0.7.0-db-mode-0600.patch"
	# Update the reachable TIFF decoder from x/image 0.21.0 to 0.44.0.
	"${FILESDIR}/${PN}-0.7.0-x-image-0.44.0.patch"
)

src_unpack() {
	default
	mv "${WORKDIR}/vendor" "${S}/vendor" || die
	go-env_set_compile_environment
}

src_compile() {
	local -x GOPROXY=off GOSUMDB=off GOTOOLCHAIN=local
	ego build -mod=vendor -trimpath -o "${PN}" .
}

src_test() {
	local -x GOPROXY=off GOSUMDB=off GOTOOLCHAIN=local
	ego test -mod=vendor -trimpath ./...
}

src_install() {
	dobin "${PN}"
	default
}

pkg_postinst() {
	ewarn "Cliphist now creates its clipboard database with mode 0600."
	ewarn "Existing databases retain their old permissions; review and restrict"
	ewarn "each user's database if needed:"
	ewarn '    chmod 600 "${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/db"'
}
