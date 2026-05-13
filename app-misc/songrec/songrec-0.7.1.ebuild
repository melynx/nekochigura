# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="An open-source Shazam client for Linux, written in Rust"
HOMEPAGE="https://github.com/marin-m/SongRec"
SRC_URI="https://github.com/marin-m/SongRec/archive/${PV}.tar.gz -> ${P}-SongRec.tar.gz"

S="${WORKDIR}/SongRec-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+pulseaudio"
# need for cargo fetch, idk how to get around it if possible
RESTRICT="strip network-sandbox"

DEPEND="
	dev-libs/openssl:=
	gui-libs/gtk:4
	gui-libs/libadwaita:1
	media-libs/alsa-lib
	sys-apps/dbus
	pulseaudio? ( media-libs/libpulse )
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-libs/glib:2
	virtual/pkgconfig
	dev-lang/rust
"

src_prepare() {
	default
	export CARGO_HOME="${WORKDIR}/cargo"
	cargo fetch --locked --target "$(rustc -vV | sed -n 's/host: //p')"
}

src_compile() {
	export CARGO_HOME="${WORKDIR}/cargo"
	local features="gui,ffmpeg"
	use pulseaudio && features+=",pulse"
	features+=",mpris"
	cargo build --release --frozen --offline --no-default-features --features "${features}"
}

src_install() {
	dobin target/release/songrec

	domenu packaging/rootfs/usr/share/applications/re.fossplant.songrec.desktop

	insinto /usr/share/icons/hicolor/scalable/apps
	doins packaging/rootfs/usr/share/icons/hicolor/scalable/apps/re.fossplant.songrec.svg

	insinto /usr/share/metainfo
	doins packaging/rootfs/usr/share/metainfo/re.fossplant.songrec.metainfo.xml

	insinto /usr/share/songrec/translations
	doins -r translations/*

	dodoc README.md
}
