# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-4 lua5-5 )

inherit lua-single cmake fcaps toolchain-funcs flag-o-matic

DESCRIPTION="A dynamic tiling Wayland compositor that doesn't sacrifice on its looks"
HOMEPAGE="https://github.com/hyprwm/Hyprland"

if [[ "${PV}" = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"
else
	SRC_URI="https://github.com/hyprwm/${PN^}/releases/download/v${PV}/source-v${PV}.tar.gz -> ${P}.gh.tar.gz"
	S="${WORKDIR}/${PN}-source"

	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0/$(ver_cut 1-3)"
IUSE="+guiutils hyprpm systemd uwsm X +dbus-session"

REQUIRED_USE="${LUA_REQUIRED_USE}"

# hyprpm (hyprland plugin manager) requires the dependencies at runtime
# so that it can clone, compile and install plugins.
HYPRPM_RDEPEND="
	app-alternatives/ninja
	>=dev-build/cmake-3.30
	dev-vcs/git
	virtual/pkgconfig
"
RDEPEND="
	hyprpm? ( ${HYPRPM_RDEPEND} )
	dev-cpp/tomlplusplus
	dev-libs/glib:2
	>=dev-libs/hyprlang-0.6.7:=
	dev-libs/libei:=
	>=dev-libs/libinput-1.29:=
	>=dev-libs/hyprgraphics-0.5.1:=
	dev-libs/re2:=
	dev-cpp/muParser:=
	>=dev-libs/udis86-1.7.2
	>=dev-libs/wayland-1.22.91
	dev-util/glslang:=
	>=gui-libs/aquamarine-0.9.5:=
	>=gui-libs/hyprcursor-0.1.9:=
	>=gui-libs/hyprutils-0.14.0:=
	>=gui-libs/hyprwire-0.2.1:=
	media-libs/lcms:=
	media-libs/libglvnd
	media-libs/mesa
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/libdrm
	>=x11-libs/libxkbcommon-1.11.0
	x11-libs/pango
	x11-libs/pixman
	x11-libs/libXcursor
	guiutils? ( gui-libs/hyprland-guiutils:= )
	X? (
		x11-libs/libxcb:0=
		x11-base/xwayland
		x11-libs/xcb-util-errors
		x11-libs/xcb-util-wm
	)
	dbus-session? ( sys-apps/dbus )
"
# dev-cpp/glaze should be only needed with hyprpm, but is needed by other
# headers.
DEPEND="
	${RDEPEND}
	${LUA_DEPS}
	>=dev-cpp/glaze-7.0.0:=
	>=dev-libs/hyprland-protocols-0.6.4
	>=dev-libs/wayland-protocols-1.49
"
BDEPEND="
	|| ( >=sys-devel/gcc-15:* >=llvm-core/clang-19:* )
	app-misc/jq
	dev-build/cmake
	>=dev-util/hyprwayland-scanner-0.4.5
	virtual/pkgconfig
"

FILECAPS=(
	cap_sys_nice usr/bin/Hyprland
)

pkg_setup() {
	lua-single_pkg_setup

	[[ ${MERGE_TYPE} == binary ]] && return

	if tc-is-gcc && ver_test $(gcc-version) -lt 15 ; then
		eerror "Hyprland requires >=sys-devel/gcc-15 to build"
		eerror "Please upgrade GCC: emerge -v1 sys-devel/gcc"
		die "GCC version is too old to compile Hyprland!"
	elif tc-is-clang && ver_test $(clang-version) -lt 19 ; then
		eerror "Hyprland requires >=llvm-core/clang-19 to build"
		eerror "Please upgrade Clang: emerge -v1 llvm-core/clang"
		die "Clang version is too old to compile Hyprland!"
	fi
}

PATCHES=(
	# A layer-surface idle inhibitor is scored for visibility only when it is
	# created and on toplevel map/unmap, never when its own layer surface maps.
	# Quickshell (caelestia's Keep Awake) creates the inhibitor before the
	# rebuilt window's first commit on every output hotplug, so the compositor
	# records "not inhibiting" and the idle lock fires with the toggle on.
	"${FILESDIR}/hyprland-recheck-idle-inhibitors-on-layer-map.patch"
)

src_prepare() {
	if use hyprpm; then
		PATCHES+=("${FILESDIR}/hyprland-0.56.0-hyprpm-set-lua.patch")
	fi
	# Apply the following patch unless compiled with gcc 16.
	# Building Hyprland with clang using libtstdc++ provided by gcc 15 hits the
	# same compilation error.
	# https://codeberg.org/hyproverlay/hyproverlay/issues/95#issuecomment-19928755
	if ! ( tc-is-gcc && ver_test $(gcc-version) -gt 16 ); then
		PATCHES+=("${FILESDIR}/hyprland-gcc15-compile-fix.patch")
	fi

	if use dbus-session; then
		sed -i \
			"s|^Exec=|Exec=/usr/libexec/hyprland-dbus-run-session-if-needed |" \
			example/hyprland.desktop.in || die
	fi

	cmake_src_prepare
}

src_configure() {
	# Pass Gentoo lua-single pkg-config/CFLAGS information to hyprpm, so that
	# runtime hyprpm update/add can build headers and plugins against the selected ELUA.
	append-cxxflags \
		"-DHYPRPM_GENTOO_LUA_PCFILE=\\\"/usr/$(get_libdir)/pkgconfig/${ELUA}.pc\\\"" \
		"-DHYPRPM_EXTRA_CFLAGS=\\\"$(lua_get_CFLAGS)\\\"" \
		"-DHYPRPM_EXTRA_CXXFLAGS=\\\"$(lua_get_CFLAGS)\\\""

	local mycmakeargs=(
		"-DBUILD_TESTING=OFF" # if enabled, creates a file inside /lib
							  # causing an error with multilib
		-DNO_HYPRPM="$(usex !hyprpm)"
		-DNO_SYSTEMD="$(usex !systemd)"
		-DNO_UWSM="$(usex !uwsm)"
		-DNO_XWAYLAND="$(usex !X)"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use dbus-session; then
		exeinto /usr/libexec
		doexe "${FILESDIR}/hyprland-dbus-run-session-if-needed"
	fi
}
