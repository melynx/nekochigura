# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Desktop defaults for Apple Silicon Macs (display, touchpad, indexing)"
HOMEPAGE="https://github.com/melynx/nekochigura"
# The files are unchanged from sys-apps/asahi-configs-2 (MIT). Its
# MOZ_ENABLE_WAYLAND profile.d file is dropped: Firefox defaults to Wayland.
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

RDEPEND="!sys-apps/asahi-configs"

src_install() {
	# Xorg: drive the apple-drm display controller with modesetting as the
	# primary GPU, and turn on touchpad natural scrolling.
	insinto /etc/X11/xorg.conf.d
	doins "${FILESDIR}"/{20-natural-scrolling,30-modesetting}.conf

	# KDE: touchpad natural scrolling, and Baloo basic indexing only.
	insinto /etc/xdg
	doins "${FILESDIR}"/{baloofilerc,kcminputrc}
}
