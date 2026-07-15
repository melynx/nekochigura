# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

MY_COMMIT="693095d45c67e6b48a9873e36af6283f05080e66"

DESCRIPTION="One UI 4 icon theme fork for illogical-impulse"
HOMEPAGE="https://github.com/end-4/OneUI4-Icons"
SRC_URI="https://github.com/end-4/OneUI4-Icons/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OneUI4-Icons-${MY_COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
RESTRICT="binchecks strip"

RDEPEND="x11-themes/hicolor-icon-theme"

src_prepare() {
	default

	local alias
	local mimetypes="OneUI/scalable/mimetypes"
	local -a broken_aliases=(
		application-x-vnc.svg
		document-illustrator.svg
		document-photoshop.svg
		gnome-mime-application-vnd.scribus.svg
		gnome-mime-application-x-bittorrent.svg
		gnome-mime-application-x-remote-connection.svg
		gnome-mime-application-x-scribus.svg
		gnome-mime-application-x-vnc.svg
	)

	# Remove upstream aliases whose relative targets do not exist.
	for alias in "${broken_aliases[@]}"; do
		rm "${mimetypes}/${alias}" || die
	done

	# Retarget aliases when the same icon is shipped at a fixed resolution.
	ln -s ../../22/mimetypes/application-illustrator.svg \
		"${mimetypes}"/document-illustrator.svg || die
	ln -s ../../16/mimetypes/image-vnd.adobe.photoshop.svg \
		"${mimetypes}"/document-photoshop.svg || die
	ln -s ../../22/mimetypes/application-illustrator.svg \
		"${mimetypes}"/gnome-mime-application-vnd.scribus.svg || die
	ln -s ../../22/mimetypes/application-x-bittorrent.svg \
		"${mimetypes}"/gnome-mime-application-x-bittorrent.svg || die
	ln -s ../../22/mimetypes/application-illustrator.svg \
		"${mimetypes}"/gnome-mime-application-x-scribus.svg || die
}

src_install() {
	local theme

	insinto /usr/share/icons
	for theme in OneUI OneUI-dark OneUI-light; do
		doins -r "${theme}"
	done
}
