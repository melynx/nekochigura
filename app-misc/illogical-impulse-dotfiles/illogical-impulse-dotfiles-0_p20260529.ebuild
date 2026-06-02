# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Dotfiles and setup scripts for the illogical-impulse Hyprland desktop"
HOMEPAGE="https://github.com/end-4/dots-hyprland"

EGIT_REPO_URI="https://github.com/end-4/dots-hyprland.git"
EGIT_COMMIT="3cb611c04e6b166c0c2b07755302f239f0c84cac"
EGIT_SUBMODULES=("*")

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	app-shells/bash
	dev-vcs/git
	net-misc/rsync
"

PATCHES=(
	"${FILESDIR}/${P}-skip-submodule-update.patch"
	"${FILESDIR}/${P}-idle-systemd-inhibit.patch"
	"${FILESDIR}/${P}-bar-exclusion-mode.patch"
	"${FILESDIR}/${P}-systeminfo-osrelease-quotes.patch"
	"${FILESDIR}/${P}-switchwall-ghostty.patch"
	"${FILESDIR}/${P}-applycolor-ghostty.patch"
	"${FILESDIR}/${P}-ghostty-theme-template.patch"
)

src_install() {
	insinto /usr/share/dots-hyprland
	doins -r .

	# Make setup entry point and shell scripts executable
	fperms +x /usr/share/dots-hyprland/setup
	find "${ED}/usr/share/dots-hyprland" -name '*.sh' -exec chmod +x {} + || die

	dobin "${FILESDIR}/illogical-impulse-setup"
}

pkg_postinst() {
	elog "To deploy the illogical-impulse dotfiles, run:"
	elog "  illogical-impulse-setup"
	elog ""
	elog "Additional flags can be passed through, e.g.:"
	elog "  illogical-impulse-setup --skip-allsetups"
	elog "  illogical-impulse-setup --skip-fish"
}
