EAPI=8

DESCRIPTION="Meta package for Intel IPU6 webcam support"
HOMEPAGE="https://github.com/intel/ipu6-drivers"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

RDEPEND="
    sys-kernel/ipu6-drivers
    media-libs/ipu6-camera-hal
    media-libs/ipu6-camera-bins
    media-plugins/gst-plugins-icamerasrc
    media-video/v4l2-relayd[systemd?]
"
