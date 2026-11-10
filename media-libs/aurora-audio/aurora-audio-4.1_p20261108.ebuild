# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# aurora-silicon/asahi-audio, the commit alarm-aurora pins (4.1.aurora2-16)
COMMIT="c967141161bea3badc7754e23d80b39ffb1bdafd"

DESCRIPTION="PipeWire and WirePlumber DSP profiles for Apple Silicon Macs (Aurora Silicon)"
HOMEPAGE="https://github.com/aurora-silicon/asahi-audio"
SRC_URI="https://github.com/aurora-silicon/asahi-audio/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/asahi-audio-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

# The speaker graphs load the bankstown, triforce and LSP LV2 plugins; the
# J293 graph adds an LSP limiter, and loud_comp needs the 1.2.37 latency fix.
RDEPEND="
	>=media-video/pipewire-1.0.2[extra,lv2,sound-server]
	>=media-video/wireplumber-0.5.16
	media-libs/alsa-ucm-conf-aurora
	>=media-libs/lsp-plugins-1.2.37[lv2]
	media-libs/bankstown-lv2
	media-libs/triforce-lv2
	sys-apps/speakersafetyd
	!media-libs/asahi-audio
"

PATCHES=(
	# Aurora's own packaging carries this: speakerguardd v2 is not installed
	# here, so keep the asahi-audio speaker graphs for every board.
	"${FILESDIR}/${PN}-restore-legacy-speaker-graphs.patch"
)

src_compile() {
	emake aliases
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install
	insinto /usr/share/wireplumber/wireplumber.conf.d
	# Speaker PCMs wake on period interrupts, so a chrony slew no longer re-prepares the sink.
	doins "${FILESDIR}/99-aurora-speaker-irq.conf"
	dodoc README.md
}
