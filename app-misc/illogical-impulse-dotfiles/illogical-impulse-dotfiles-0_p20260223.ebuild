# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Dotfiles and setup scripts for the illogical-impulse Hyprland desktop"
HOMEPAGE="https://github.com/end-4/dots-hyprland"

EGIT_REPO_URI="https://github.com/end-4/dots-hyprland.git"
EGIT_COMMIT="8bf279e571ff14a653d956eb23f63e54ae88dc8b"
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
	"${FILESDIR}/${P}-fix-os-detection.patch"
	"${FILESDIR}/${P}-skip-submodule-update.patch"
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
