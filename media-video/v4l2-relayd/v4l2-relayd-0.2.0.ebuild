# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="Stream content from GStreamer video source into v4l2loopback device"
HOMEPAGE="https://gitlab.com/vicamo/v4l2-relayd"
MY_P="${PN}-upstream-${PV}"
SRC_URI="https://gitlab.com/vicamo/${PN}/-/archive/upstream/${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="systemd"

RDEPEND="
	>=dev-libs/glib-2.36:2
	>=media-libs/gstreamer-1.0:1.0
	>=media-libs/gst-plugins-base-1.0:1.0
	media-video/v4l2loopback
	systemd? ( sys-apps/systemd )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	dev-build/autoconf
	dev-build/automake
	dev-build/libtool
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_with systemd systemdsystemunitdir "$(systemd_get_systemunitdir)")
		$(use_with systemd systemdsystemgeneratordir "$(systemd_get_systemgeneratordir)")
		$(use_with systemd modulesloaddir "$(systemd_get_utildir)/modules-load.d")
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	if ! use systemd; then
		# Install configuration files even without systemd
		insinto /etc/modprobe.d
		doins data/etc/modprobe.d/v4l2-relayd.conf

		insinto /etc/default
		doins data/etc/default/v4l2-relayd
	else
		# Create instance configuration directory
		keepdir /etc/v4l2-relayd.d
	fi

	# Remove libtool files
	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	elog "v4l2-relayd requires v4l2loopback kernel module to be loaded."
	elog "You may need to run:"
	elog "  modprobe v4l2loopback"
	elog ""

	if use systemd; then
		elog "The v4l2-relayd.service is a manager service that coordinates instances."
		elog "You must create instance configuration files to run v4l2-relayd."
		elog ""
		elog "To set up an instance:"
		elog "  1. Create a config file in /etc/v4l2-relayd.d/<name>.conf with:"
		elog "     VIDEOSRC=\"videotestsrc\"  # or your video source"
		elog "     FORMAT=\"YUY2\""
		elog "     WIDTH=\"1280\""
		elog "     HEIGHT=\"720\""
		elog "     FRAMERATE=\"30/1\""
		elog "     CARD_LABEL=\"Dummy video device\"  # match v4l2loopback card_label"
		elog "     #SPLASHSRC=\"filesrc location=/path/to/splash.png ! pngdec\""
		elog "     #EXTRA_OPTS=\"\""
		elog "  2. Reload systemd to pick up the new instance:"
		elog "     systemctl daemon-reload"
		elog "  3. Start the instance:"
		elog "     systemctl start v4l2-relayd@<name>.service"
		elog ""
		elog "The v4l2-relayd.service will automatically manage all instances"
		elog "that have .conf files in /etc/v4l2-relayd.d/"
	else
		elog "Example usage:"
		elog "  v4l2-relayd -i videotestsrc \\"
		elog "    -o \"appsrc name=appsrc caps=video/x-raw,format=YUY2,width=1280,height=720,framerate=30/1 ! videoconvert ! v4l2sink device=/dev/video0\""
	fi
}

