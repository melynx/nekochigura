# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Soothing pastel theme for Neovim"
HOMEPAGE="https://github.com/catppuccin/nvim"
SRC_URI="https://github.com/catppuccin/nvim/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nvim-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND=">=app-editors/neovim-0.8"
RDEPEND=">=app-editors/neovim-0.8"

src_compile() {
	local -x XDG_RUNTIME_DIR="${T}/run"
	mkdir -p "${XDG_RUNTIME_DIR}" || die
	chmod 0700 "${XDG_RUNTIME_DIR}" || die

	nvim --headless -u NONE -i NONE -n \
		--cmd "helptags ${S}/doc" +q || die "failed to generate help tags"
}

src_test() {
	local -x HOME="${T}/home"
	local -x XDG_CACHE_HOME="${T}/cache"
	local -x XDG_DATA_HOME="${T}/data"
	local -x XDG_RUNTIME_DIR="${T}/run"
	local -x XDG_STATE_HOME="${T}/state"
	mkdir -p "${HOME}" "${XDG_CACHE_HOME}" "${XDG_DATA_HOME}" \
		"${XDG_STATE_HOME}" || die

	local colorscheme
	for colorscheme in catppuccin-nvim catppuccin-latte catppuccin-frappe \
		catppuccin-macchiato catppuccin-mocha; do
		nvim --headless -u NONE -i NONE -n \
			--cmd "set runtimepath^=${S}" \
			-c "lua require('catppuccin').setup()" \
			-c "colorscheme ${colorscheme}" +q || \
				die "failed to load ${colorscheme}"
	done
}

src_install() {
	insinto "/usr/share/nvim/site/pack/nekochigura/start/${PN}"
	doins -r colors doc lua

	einstalldocs
}
