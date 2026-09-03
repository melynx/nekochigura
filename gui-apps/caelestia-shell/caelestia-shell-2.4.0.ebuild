# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# Commit referenced by the v2.4.0 tag.
EGIT_COMMIT="24aa15eefdb146350d2548c0a015b04eddbd1008"

DESCRIPTION="Caelestia Quickshell desktop shell (Hyprland)"
HOMEPAGE="https://github.com/caelestia-dots/shell"
SRC_URI="https://github.com/caelestia-dots/shell/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/shell-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

# Qt6 6.9+ (upstream: qt_standard_project_setup(REQUIRES 6.9)).
COMMON_DEPEND="
	>=dev-qt/qtbase-6.9:6[concurrent,dbus,gui,network,sql,widgets]
	>=dev-qt/qtdeclarative-6.9:6
	sci-libs/libqalculate
	media-libs/aubio
	media-video/pipewire
	media-sound/libcava
	sys-apps/lm-sensors
	sci-libs/fftw:3.0=
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="
	${COMMON_DEPEND}
	>=dev-qt/qtimageformats-6.9:6
	>=dev-qt/qtshadertools-6.9:6
	>=gui-apps/quickshell-0.3.0_p20260710
	app-misc/caelestia-cli
	gui-libs/m3shapes
	app-misc/ddcutil
	app-misc/brightnessctl
	app-shells/fish
	dev-libs/libxml2
	gui-apps/swappy
	gui-apps/wl-clipboard
	gui-wm/hyprland
	media-fonts/material-symbols-variable
	media-fonts/rubik-vf
	media-fonts/nerdfonts[cascadiacode]
	media-fonts/noto
	media-fonts/noto-cjk
	media-fonts/noto-emoji
	net-misc/networkmanager
	sys-power/power-profiles-daemon
	sys-process/procps
	x11-libs/libnotify
	x11-misc/xkeyboard-config
"
BDEPEND="
	>=dev-qt/qtshadertools-6.9:6
	virtual/pkgconfig
"

# Two of these needed a rebase for 2.4.0 and are version-qualified so the 2.2.0
# and 2.3.0 ebuilds keep the copies that match their trees. The 2.3.0 keyboard
# patch is gone: 2.4.0 moved the layout toast into the C++ plugin, which already
# suppresses the transient no-main-keyboard gap it was working around.
PATCHES=(
	# Select one provider-neutral facial-authentication context and add Gaze
	# alongside the existing Howdy PAM backend.
	"${FILESDIR}/${PN}-${PV}-configurable-facial-provider.patch"

	# Add missing Qt includes (QObject, QVariant, QQmlEngine, QString, QTimer,
	# QPointer, QStringList) that upstream relied on transitively; Qt 6.11
	# dropped those transitive includes so the plugin fails to build without them.
	"${FILESDIR}/${PN}-${PV}-qt6.11-includes.patch"

	# The Keep Awake idle inhibitor hangs off a PanelWindow built once inline
	# in a Singleton. A monitor hotplug destroys it and nothing rebuilds it, so
	# the toggle silently stops inhibiting while still reporting itself active.
	"${FILESDIR}/${PN}-rebuild-idle-inhibitor-window.patch"

	# Raise the notification's sender when its default action is invoked.
	# Windows carrying a focus_on_activate=false rule cannot raise themselves
	# (Wayland cannot distinguish an app's self-activation from a user click),
	# and the daemon is the only party that knows the click happened.
	"${FILESDIR}/${PN}-focus-sender-on-notification-action.patch"
)

src_configure() {
	local mycmakeargs=(
		# Upstream installs with prefix "/" and relative usr/... dests; the cmake
		# eclass defaults the prefix to /usr, which would yield /usr/usr/lib.
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/"
		# GOTCHA: Gentoo ships Qt6 QML under lib64; the upstream default
		# usr/lib/qt6/qml makes Quickshell fail with
		# `module "Caelestia.Config" is not installed`.
		-DINSTALL_QMLDIR=usr/lib64/qt6/qml
		# Release tarball has no .git, so upstream's git describe/rev-parse
		# fatal-errors -- supply version metadata explicitly.
		-DVERSION="${PV}"
		-DGIT_REVISION="${EGIT_COMMIT}"
		-DDISTRIBUTOR="nekochigura"
	)
	cmake_src_configure
}

pkg_postinst() {
	elog "Caelestia shell installed. This replaces the manual"
	elog "cmake/ninja + 'cmake --install' workflow under ~/.config/quickshell/caelestia."
	elog
	elog "Your update-safe overrides in ~/.config/caelestia/ are NOT touched by"
	elog "this package: hypr-user.lua, hypr-vars.lua, user-config.fish, shell.json."
	elog
	elog "Launch with:  caelestia shell   (or: qs -c caelestia)"
}
