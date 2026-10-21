# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Precompiled talosctl client for interacting with the Talos API"
HOMEPAGE="https://www.talos.dev/"

MY_PV="${PV/_rc/-rc.}"
BASE_URI="https://github.com/siderolabs/talos/releases/download/v${MY_PV}"
SRC_URI="
	amd64? ( ${BASE_URI}/talosctl-linux-amd64 -> talosctl-amd64-v${MY_PV} )
	arm64? ( ${BASE_URI}/talosctl-linux-arm64 -> talosctl-arm64-v${MY_PV} )
	arm? ( ${BASE_URI}/talosctl-linux-armv7 -> talosctl-armv7-v${MY_PV} )
"

S="${WORKDIR}"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

RESTRICT="strip"

QA_PREBUILT="usr/bin/talosctl"

src_install() {
	if use arm; then
		newbin "${DISTDIR}"/talosctl-armv7-v${MY_PV} talosctl
	fi
	if use arm64; then
		newbin "${DISTDIR}"/talosctl-arm64-v${MY_PV} talosctl
	fi
	if use amd64; then
		newbin "${DISTDIR}"/talosctl-amd64-v${MY_PV} talosctl
	fi
}
