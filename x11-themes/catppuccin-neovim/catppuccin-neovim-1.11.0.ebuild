# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Soothing pastel theme for Neovim"
HOMEPAGE="https://github.com/catppuccin/nvim"
SRC_URI="https://github.com/catppuccin/nvim/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nvim-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="app-editors/neovim"

src_install() {
	insinto /usr/share/nvim/runtime/colors
	doins "${S}"/colors/*.vim

	insinto /usr/share/nvim/runtime/lua/catppuccin
	doins -r "${S}"/lua/catppuccin/.

	insinto /usr/share/nvim/runtime/lua/barbecue/theme
	doins "${S}"/lua/barbecue/theme/*.lua

	insinto /usr/share/nvim/runtime/lua/lualine/themes
	doins "${S}"/lua/lualine/themes/*.lua

	insinto /usr/share/nvim/runtime/lua/reactive/presets
	doins "${S}"/lua/reactive/presets/*.lua

	einstalldocs
}
