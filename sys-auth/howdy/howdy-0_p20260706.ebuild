# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit meson python-single-r1 pam

# Untagged v3 (meson + compiled pam_howdy.so). Pin master snapshot.
EGIT_COMMIT="d3ab99382f88f043d15f15c1450ab69433892a1c"
# dlib recognition models (pinned commit of davisking/dlib-models)
DLIB_MODELS_COMMIT="fd81b6308a6a73d4ce08859eb2f4b628a21e27a2"
DLIB_MODELS_URI="https://github.com/davisking/dlib-models/raw/${DLIB_MODELS_COMMIT}"

DESCRIPTION="Windows Hello-style facial authentication for Linux (PAM, dlib/OpenCV)"
HOMEPAGE="https://github.com/boltgolt/howdy"
SRC_URI="
	https://github.com/boltgolt/howdy/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
	${DLIB_MODELS_URI}/dlib_face_recognition_resnet_model_v1.dat.bz2
	${DLIB_MODELS_URI}/mmod_human_face_detector.dat.bz2
	${DLIB_MODELS_URI}/shape_predictor_5_face_landmarks.dat.bz2
"
S="${WORKDIR}/howdy-${EGIT_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		sci-libs/dlib[python,${PYTHON_USEDEP}]
		media-libs/opencv[python,v4l,${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
	')
	sys-libs/pam
	dev-libs/libevdev
	dev-libs/inih
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	sys-devel/gettext
"

PATCHES=(
	"${FILESDIR}/${PN}-blas-singlethread.patch"
	"${FILESDIR}/${PN}-config-defaults.patch"
)

src_configure() {
	local emesonargs=(
		-Dpython_path="${PYTHON}"
		-Dpam_dir="$(getpam_mod_dir)"
		-Dconfig_dir="${EPREFIX}/etc/howdy"
		-Ddlib_data_dir="${EPREFIX}/usr/share/dlib-data"
		-Duser_models_dir="${EPREFIX}/etc/howdy/models"
		-Dinstall_in_site_packages=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# Ship the pre-fetched dlib recognition models (unpacked by src_unpack)
	insinto /usr/share/dlib-data
	doins "${WORKDIR}"/dlib_face_recognition_resnet_model_v1.dat
	doins "${WORKDIR}"/mmod_human_face_detector.dat
	doins "${WORKDIR}"/shape_predictor_5_face_landmarks.dat
}

pkg_postinst() {
	elog "Howdy facial auth installed. To finish setup:"
	elog "  1. Enroll your face (look at the IR camera):"
	elog "         sudo howdy add"
	elog "  2. Verify:  sudo howdy list   and   sudo howdy test"
	elog
	elog "config.ini defaults are tuned for this machine (IR device_path,"
	elog "dark_threshold=90, certainty=4.0). Adjust with: sudo howdy config"
	elog
	elog "The caelestia lock screen enables face unlock via shell.json:"
	elog '  "lock": { "enableHowdy": true, "triggerHowdyOnWake": true }'
	elog
	elog "Note: single-threaded BLAS is forced in compare.py/cli.py to avoid an"
	elog "OpenBLAS deadlock in dlib's ResNet on some CPUs (e.g. Lunar Lake)."
}
