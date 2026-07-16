# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTS_COMMIT="446504ad427297dcbe5ee4a3d5bda1c458207cd9"
SHAPES_COMMIT="e31ec4cb4ebf6a46b267f5c42eabf6874916fa16"
SHAPES_PN="rounded-polygon-qmljs"
SHAPES_PATH="dots/.config/quickshell/ii/modules/common/widgets/shapes"

DESCRIPTION="Dotfiles and setup scripts for the illogical-impulse Hyprland desktop"
HOMEPAGE="https://github.com/end-4/dots-hyprland"
SRC_URI="
	https://github.com/end-4/dots-hyprland/archive/${DOTS_COMMIT}.tar.gz
		-> ${P}.gh.tar.gz
	https://github.com/end-4/${SHAPES_PN}/archive/${SHAPES_COMMIT}.tar.gz
		-> ${PN}-${SHAPES_PN}-${SHAPES_COMMIT}.gh.tar.gz
"
S="${WORKDIR}/dots-hyprland-${DOTS_COMMIT}"

LICENSE="GPL-3 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	app-shells/bash
	dev-vcs/git
	net-misc/rsync
"

PATCHES=(
	"${FILESDIR}/${PN}-skip-submodule-update.patch"
	"${FILESDIR}/${PN}-idle-systemd-inhibit.patch"
	"${FILESDIR}/${PN}-bar-exclusion-mode.patch"
	"${FILESDIR}/${PN}-systeminfo-osrelease-quotes.patch"
	"${FILESDIR}/${PN}-switchwall-ghostty.patch"
	"${FILESDIR}/${PN}-applycolor-ghostty.patch"
	"${FILESDIR}/${PN}-ghostty-theme-template.patch"
)

src_unpack() {
	default
	rmdir "${S}/${SHAPES_PATH}" || die
	mv "${WORKDIR}/${SHAPES_PN}-${SHAPES_COMMIT}" \
		"${S}/${SHAPES_PATH}" || die
}

src_install() {
	local file

	insinto /usr/share/dots-hyprland
	doins -r .

	# doins strips file modes; restore every upstream executable bit.
	while IFS= read -r -d '' file; do
		fperms +x "/usr/share/dots-hyprland/${file#./}"
	done < <(find . -type f -perm /111 -print0)
	find "${ED}/usr/share/dots-hyprland" -name '*.sh' \
		-exec chmod +x {} + || die

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
