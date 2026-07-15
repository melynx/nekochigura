# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.88.0"

inherit cargo desktop xdg

DESCRIPTION="Open-source Shazam client for Linux written in Rust"
HOMEPAGE="https://songrec.fossplant.re/ https://github.com/marin-m/SongRec"
SRC_URI="
	https://github.com/marin-m/SongRec/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
	https://raw.githubusercontent.com/melynx/nekochigura-dependencies/master/app-misc/${PN}/${P}-vendor.tar.xz
"
S="${WORKDIR}/SongRec-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+pulseaudio"

ECARGO_VENDOR="${S}/vendor"

DEPEND="
	dev-libs/glib:2
	>=gui-libs/gtk-4.14:4
	>=gui-libs/libadwaita-1.5:1
	media-libs/alsa-lib
	media-video/pipewire
	>=net-libs/libsoup-3.4:3.0
	pulseaudio? ( media-libs/libpulse )
"
RDEPEND="
	${DEPEND}
	media-video/ffmpeg
	sys-apps/dbus
"
BDEPEND="
	dev-util/blueprint-compiler
	llvm-core/clang
	sys-devel/gettext
	virtual/pkgconfig
"

src_unpack() {
	default

	mv "${WORKDIR}"/vendor "${S}"/vendor || die
	cargo_gen_config
}

src_configure() {
	local myfeatures=(
		gui
		ffmpeg
		mpris
		pipewire
		$(usev pulseaudio pulse)
	)

	cargo_src_configure --no-default-features
}

src_compile() {
	cargo_src_compile
}

src_install() {
	dobin target/release/songrec

	domenu packaging/rootfs/usr/share/applications/re.fossplant.songrec.desktop

	insinto /usr/share/icons
	doins -r packaging/rootfs/usr/share/icons/hicolor

	insinto /usr/share/metainfo
	doins packaging/rootfs/usr/share/metainfo/re.fossplant.songrec.metainfo.xml

	insinto /usr/share
	doins -r translations/locale

	cp packaging/rootfs/usr/share/man/man1/songrec.1.gz "${T}" || die
	gunzip "${T}"/songrec.1.gz || die
	doman "${T}"/songrec.1
	dodoc README.md
}
