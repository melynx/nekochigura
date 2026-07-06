# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Caelestia desktop metapackage (shell + cli)"
HOMEPAGE="https://github.com/caelestia-dots"
S="${WORKDIR}"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=gui-apps/caelestia-shell-2.1.0
	app-misc/caelestia-cli
"

pkg_postinst() {
	elog "Deploy the Caelestia dotfiles with:  caelestia install --no-packages"
	elog "(config files only; Portage provides the deps). See app-misc/caelestia-cli."
}
