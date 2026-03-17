# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Toolkit for building desktop widgets using QtQuick"
HOMEPAGE="https://quickshell.org/"

EGIT_REPO_URI="https://github.com/quickshell-mirror/quickshell.git"
EGIT_COMMIT="706d6de7b0236cec2c25556e284b91104a4e834b"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
# Upstream recommends leaving all build options enabled by default
IUSE="+crash-handler +jemalloc +sockets +wayland +layer-shell +session-lock +toplevel-management +screencopy +screencopy-icc +screencopy-wlr +screencopy-hyprland-toplevel +X +pipewire +tray +mpris +pam +polkit +greetd +upower +notifications +hyprland +hyprland-ipc +hyprland-global-shortcuts +hyprland-focus-grab +hyprland-surface-extensions +i3 +i3-ipc +bluetooth +network"

RDEPEND="
	dev-qt/qtbase:6[dbus]
	dev-qt/qtsvg:6
	dev-qt/qt5compat:6

	dev-qt/qtimageformats:6
	dev-qt/qtmultimedia:6
	dev-qt/qtpositioning:6
	dev-qt/qtquicktimeline:6
	dev-qt/qtsensors:6
	dev-qt/qttools:6
	dev-qt/qttranslations:6
	dev-qt/qtvirtualkeyboard:6
	dev-qt/qtwayland:6
	kde-apps/kdialog
	kde-frameworks/syntax-highlighting:6
	kde-frameworks/kirigami

	crash-handler? ( dev-cpp/cpptrace[libunwind] )
	jemalloc? ( dev-libs/jemalloc )
	wayland? (
		dev-libs/wayland
		dev-qt/qtwayland:6
	)
	screencopy? (
		x11-libs/libdrm
		media-libs/mesa
	)
	X? ( x11-libs/libxcb )
	pipewire? ( media-video/pipewire )
	pam? ( sys-libs/pam )
	polkit? ( sys-auth/polkit )
	bluetooth? ( net-wireless/bluez )
"
DEPEND="${RDEPEND}"
BDEPEND="
	|| ( >=sys-devel/gcc-14:* >=llvm-core/clang-17:* )

	dev-util/spirv-tools
	dev-qt/qtshadertools:6
	wayland? (
		dev-util/wayland-scanner
		dev-libs/wayland-protocols
	)
	dev-cpp/cli11
	dev-build/ninja
	dev-build/cmake
	dev-vcs/git
	virtual/pkgconfig
"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=RelWithDebInfo
		-DDISTRIBUTOR="Gentoo Illogical-Impulses"
		-DINSTALL_QML_PREFIX="lib64/qt6/qml"
		-DCRASH_HANDLER=$(usex crash-handler ON OFF)
		-DUSE_JEMALLOC=$(usex jemalloc ON OFF)
		-DSOCKETS=$(usex sockets ON OFF)
		-DWAYLAND=$(usex wayland ON OFF)
		-DWAYLAND_WLR_LAYERSHELL=$(usex layer-shell ON OFF)
		-DWAYLAND_SESSION_LOCK=$(usex session-lock ON OFF)
		-DWAYLAND_TOPLEVEL_MANAGEMENT=$(usex toplevel-management ON OFF)
		-DSCREENCOPY=$(usex screencopy ON OFF)
		-DSCREENCOPY_ICC=$(usex screencopy-icc ON OFF)
		-DSCREENCOPY_WLR=$(usex screencopy-wlr ON OFF)
		-DSCREENCOPY_HYPRLAND_TOPLEVEL=$(usex screencopy-hyprland-toplevel ON OFF)
		-DX11=$(usex X ON OFF)
		-DSERVICE_PIPEWIRE=$(usex pipewire ON OFF)
		-DSERVICE_STATUS_NOTIFIER=$(usex tray ON OFF)
		-DSERVICE_MPRIS=$(usex mpris ON OFF)
		-DSERVICE_PAM=$(usex pam ON OFF)
		-DSERVICE_POLKIT=$(usex polkit ON OFF)
		-DSERVICE_GREETD=$(usex greetd ON OFF)
		-DSERVICE_UPOWER=$(usex upower ON OFF)
		-DSERVICE_NOTIFICATIONS=$(usex notifications ON OFF)
		-DHYPRLAND=$(usex hyprland ON OFF)
		-DHYPRLAND_IPC=$(usex hyprland-ipc ON OFF)
		-DHYPRLAND_GLOBAL_SHORTCUTS=$(usex hyprland-global-shortcuts ON OFF)
		-DHYPRLAND_FOCUS_GRAB=$(usex hyprland-focus-grab ON OFF)
		-DHYPRLAND_SURFACE_EXTENSIONS=$(usex hyprland-surface-extensions ON OFF)
		-DI3=$(usex i3 ON OFF)
		-DI3_IPC=$(usex i3-ipc ON OFF)
		-DBLUETOOTH=$(usex bluetooth ON OFF)
		-DNETWORK=$(usex network ON OFF)
	)
	cmake_src_configure
}
