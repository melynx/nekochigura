# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake multiprocessing

MY_PV="${PV/_rc/rc}"
BORINGSSL_COMMIT="156c7b75ae9b8c3b3f847acf264f17594c3859fb"
CURL_VERSION="8.21.0"

DESCRIPTION="Active curl-impersonate fork with HTTP/3 and current browser profiles"
HOMEPAGE="https://github.com/lexiforest/curl-impersonate"
SRC_URI="
	https://github.com/lexiforest/${PN}/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz
	https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
	https://github.com/google/brotli/archive/refs/tags/v1.2.0.tar.gz
		-> brotli-1.2.0.tar.gz
	https://github.com/google/boringssl/archive/${BORINGSSL_COMMIT}.zip
		-> boringssl-${BORINGSSL_COMMIT}.zip
	https://github.com/nghttp2/nghttp2/releases/download/v1.63.0/nghttp2-1.63.0.tar.bz2
	https://github.com/ngtcp2/ngtcp2/releases/download/v1.20.0/ngtcp2-1.20.0.tar.bz2
	https://github.com/ngtcp2/nghttp3/releases/download/v1.15.0/nghttp3-1.15.0.tar.bz2
	https://github.com/curl/curl/archive/curl-8_21_0.tar.gz
		-> curl-${CURL_VERSION}.tar.gz
	https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz
"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="
	Apache-2.0 BSD curl ISC MIT ZLIB
	|| ( BSD GPL-2 )
	|| ( GPL-2+ LGPL-3+ )
	GPL-3+ unicode
"
SLOT="0/4"
KEYWORDS="~amd64"
IUSE="clients"

RDEPEND="app-misc/ca-certificates"
BDEPEND="
	app-arch/unzip
	dev-build/autoconf
	dev-build/automake
	dev-build/cmake
	dev-build/libtool
	dev-build/ninja
	dev-lang/go
	dev-lang/perl
	dev-util/gperf
	virtual/pkgconfig
"

DOCS=( README.md )

src_unpack() {
	unpack "${P}.tar.gz"
}

src_prepare() {
	local -A archives=(
		[ZLIB]="zlib-1.3.1.tar.gz"
		[ZSTD]="zstd-1.5.7.tar.gz"
		[BROTLI]="brotli-1.2.0.tar.gz"
		[BORINGSSL]="boringssl-${BORINGSSL_COMMIT}.zip"
		[NGHTTP2]="nghttp2-1.63.0.tar.bz2"
		[NGTCP2]="ngtcp2-1.20.0.tar.bz2"
		[NGHTTP3]="nghttp3-1.15.0.tar.bz2"
		[CURL]="curl-${CURL_VERSION}.tar.gz"
	)
	local dep

	for dep in "${!archives[@]}"; do
		sed -i \
			"s|^set(${dep}_URL .*|set(${dep}_URL \"file://${DISTDIR}/${archives[${dep}]}\")|" \
			CMakeLists.txt || die
	done

	# The wrappers use no Bash-only syntax.
	sed -i '1s|.*|#!/bin/sh|' bin/curl_* || die

	cmake_src_prepare
}

src_configure() {
	local jobs="$(get_makeopts_jobs)"
	local libidn_archive="libidn2-2.3.7.tar.gz"

	mkdir -p "${BUILD_DIR}/deps/downloads" || die
	ln -s "${DISTDIR}/${libidn_archive}" \
		"${BUILD_DIR}/deps/downloads/${libidn_archive}" || die

	emake \
		BUILD_DIR="${BUILD_DIR}" \
		JOBS="${jobs}" \
		prepare-libidn2

	local mycmakeargs=(
		-DSUBJOBS="${jobs}"
		-DCURL_CA_BUNDLE="${EPREFIX}/etc/ssl/certs/ca-certificates.crt"
		-DCURL_CA_PATH="${EPREFIX}/etc/ssl/certs"
	)
	cmake_src_configure
}

src_test() {
	emake BUILD_DIR="${BUILD_DIR}" checkbuild
}

src_install() {
	cmake_src_install

	# net-misc/curl owns the public headers.  Upstream also installs internal
	# CMake object directories when its curl dependency is copied into place.
	rm -rf \
		"${ED}/usr/include/curl" \
		"${ED}/usr/$(get_libdir)/CMakeFiles" || die
	rm -f "${ED}/usr/$(get_libdir)"/libcurl-impersonate*.a || die

	if ! use clients; then
		find "${ED}/usr/bin" -type f -name 'curl_*' -delete || die
	fi
}
