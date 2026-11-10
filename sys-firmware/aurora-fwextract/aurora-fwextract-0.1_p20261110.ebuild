# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1

# aurora-silicon/aurora-installer: its standalone Python firmware library
COMMIT="04bf73ccf416c3af86ffa0feafb43547bb978949"

DESCRIPTION="Apple Silicon vendor firmware extractor (Aurora Silicon)"
HOMEPAGE="https://github.com/aurora-silicon/aurora-installer"
SRC_URI="https://github.com/aurora-silicon/aurora-installer/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/aurora-installer-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# img4.py loads liblzfse.so.1 with ctypes to unpack the kernelcache firmware.
RDEPEND="
	${PYTHON_DEPS}
	app-arch/lzfse
	app-arch/tar
"
# python_domodule byte-compiles at install time.
BDEPEND="${PYTHON_DEPS}"

src_compile() {
	:
}

src_install() {
	python_domodule asahi_firmware
	python_newscript "${FILESDIR}/aurora-fwextract.py" aurora-fwextract
	newdoc asahi_firmware/README.md README.asahi_firmware.md
}
