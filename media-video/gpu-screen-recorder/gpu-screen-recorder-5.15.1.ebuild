# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fcaps meson

DESCRIPTION="A screen recorder that has minimal impact on system performance"
HOMEPAGE="https://git.dec05eba.com/gpu-screen-recorder/about"
SRC_URI="https://dec05eba.com/snapshot/${PN}.git.${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="nvidia-suspend +pipewire systemd"

COMMON_DEPEND="
	dev-libs/wayland
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/libva
	media-video/ffmpeg[vulkan]
	pipewire? ( media-video/pipewire )
	sys-apps/dbus
	sys-libs/libcap
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXfixes
	x11-libs/libXrandr
"
DEPEND="
	${COMMON_DEPEND}
	dev-util/vulkan-headers
"
RDEPEND="
	${COMMON_DEPEND}
	media-libs/libjpeg-turbo
	media-libs/vulkan-loader
"
BDEPEND="
	dev-util/wayland-scanner
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-5.15.1-dbus-without-pipewire.patch"
)

FILECAPS=(
	cap_sys_admin usr/bin/gsr-kms-server
)

src_configure() {
	local emesonargs=(
		-Dcapabilities=false
		-Dplugin_examples=false
		$(meson_use nvidia-suspend nvidia_suspend_fix)
		$(meson_use pipewire app_audio)
		$(meson_use pipewire portal)
		$(meson_use systemd)
	)
	meson_src_configure
}
