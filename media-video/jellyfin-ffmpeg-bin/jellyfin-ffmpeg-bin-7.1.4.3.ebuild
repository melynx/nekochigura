# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream tags releases as <ffmpeg-version>-<jellyfin-revision>, e.g. 7.1.4-3.
# Portage cannot carry two hyphens in a version, so the revision becomes the
# fourth component: 7.1.4.3 -> 7.1.4-3.
MY_PV="${PV%.*}-${PV##*.}"

DESCRIPTION="FFmpeg build with Jellyfin's patches, including CUDA Dolby Vision tone mapping"
HOMEPAGE="https://github.com/jellyfin/jellyfin-ffmpeg"
SRC_URI="
	amd64? (
		https://github.com/jellyfin/jellyfin-ffmpeg/releases/download/v${MY_PV}/jellyfin-ffmpeg_${MY_PV}_portable_linux64-gpl.tar.xz
			-> ${P}-linux64.tar.xz
	)
	arm64? (
		https://github.com/jellyfin/jellyfin-ffmpeg/releases/download/v${MY_PV}/jellyfin-ffmpeg_${MY_PV}_portable_linuxarm64-gpl.tar.xz
			-> ${P}-linuxarm64.tar.xz
	)
"
S="${WORKDIR}"

# Upstream ships the GPL build; the bundled encoders make it GPL-3 in practice.
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# No RDEPEND on purpose: the portable build is statically linked against
# everything except glibc, so it needs nothing at runtime and cannot collide with
# the system FFmpeg's sonames. Verified with ldd — only libm, libdl, libmvec,
# libpthread and libc. It deliberately does not depend on media-video/ffmpeg
# either; the two are independent and both may be installed.

# Prebuilt upstream binaries: do not strip, and do not expect them under /usr/bin.
RESTRICT="strip"
QA_PREBUILT="usr/lib/jellyfin-ffmpeg/.*"

# Installed outside the default PATH on purpose. Jellyfin is pointed at this
# explicitly; nothing else on the system should pick it up by accident.
JF_DIR="/usr/lib/${PN%-bin}"

src_install() {
	exeinto "${JF_DIR}"
	doexe ffmpeg ffprobe
}

pkg_postinst() {
	elog "Installed to ${JF_DIR}, deliberately outside PATH."
	elog "Your system media-video/ffmpeg is untouched and remains the default."
	elog ""
	elog "To make Jellyfin use this build, set the FFmpeg path in:"
	elog "  Dashboard -> Playback -> Transcoding -> FFmpeg path"
	elog "to:"
	elog "  ${JF_DIR}/ffmpeg"
	elog ""
	elog "Editing /etc/jellyfin/encoding.xml by hand also works, but Jellyfin"
	elog "owns that file and rewrites it, so the dashboard is safer."
	elog ""
	elog "Why this package exists: Dolby Vision Profile 5 tone mapping on NVIDIA"
	elog "needs the tonemap_cuda filter, which is a Jellyfin patch and is not part"
	elog "of upstream FFmpeg. Without it Jellyfin emits a bare setparams relabel"
	elog "and DV P5 content plays with a green and magenta cast."
	elog ""
	elog "Verify after switching:"
	elog "  ${JF_DIR}/ffmpeg -filters | grep tonemap_cuda"
	elog "  grep 'Available filters' /var/log/jellyfin/log_\$(date +%Y%m%d).log | tail -1"
	elog ""
	elog "To revert, clear the FFmpeg path field; Jellyfin falls back to the"
	elog "system ffmpeg with no rebuild required."
}
