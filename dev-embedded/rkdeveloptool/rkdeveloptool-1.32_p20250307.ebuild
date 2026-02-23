# Copyright 2025 czl
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

HASH="304f073752fd25c854e1bcf05d8e7f925b1f4e14"

DESCRIPTION="Tool from Rockchip to communicate with Rockusb devices"
HOMEPAGE="
	http://opensource.rock-chips.com/wiki_Rkdeveloptool
	https://github.com/rockchip-linux/rkdeveloptool
"
SRC_URI="https://github.com/rockchip-linux/rkdeveloptool/archive/${HASH}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${HASH}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="virtual/libusb:1"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

DOCS=( Readme.txt 99-rk-rockusb.rules parameter_gpt.txt )

src_prepare() {
	default
	sed -i 's/-Werror//' Makefile.am || die "sed failed"
	eautoreconf
}
