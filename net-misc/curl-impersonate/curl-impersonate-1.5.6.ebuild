# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multiprocessing

BORINGSSL_COMMIT="673e61fc215b178a90c0e67858bbf162c8158993"
CURL_VERSION="8.15.0"

DESCRIPTION="Active curl-impersonate fork with more versions and build targets"
HOMEPAGE="https://github.com/lexiforest/curl-impersonate"
SRC_URI="
	https://github.com/lexiforest/${PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz
	https://github.com/facebook/zstd/releases/download/v1.5.6/zstd-1.5.6.tar.gz
	https://github.com/google/brotli/archive/refs/tags/v1.2.0.tar.gz
		-> brotli-1.2.0.tar.gz
	https://github.com/google/boringssl/archive/${BORINGSSL_COMMIT}.zip
		-> boringssl-${BORINGSSL_COMMIT}.zip
	https://github.com/nghttp2/nghttp2/releases/download/v1.63.0/nghttp2-1.63.0.tar.bz2
	https://github.com/ngtcp2/ngtcp2/releases/download/v1.20.0/ngtcp2-1.20.0.tar.bz2
	https://github.com/ngtcp2/nghttp3/releases/download/v1.15.0/nghttp3-1.15.0.tar.bz2
	https://ftp.gnu.org/gnu/libunistring/libunistring-1.1.tar.gz
	https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz
	https://github.com/curl/curl/archive/curl-8_15_0.tar.gz
		-> curl-${CURL_VERSION}.tar.gz
"

LICENSE="
	Apache-2.0 BSD curl ISC MIT ZLIB
	|| ( BSD GPL-2 )
	|| ( GPL-2+ LGPL-3+ )
	|| ( FDL-1.2 GPL-3+ )
	GPL-3+ unicode
"
SLOT="0/4"
KEYWORDS="amd64"
IUSE="clients"

RDEPEND="app-misc/ca-certificates"
BDEPEND="
	app-arch/unzip
	app-shells/bash
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
	default

	local archive
	for archive in \
		"zlib-1.3.1.tar.gz" \
		"zstd-1.5.6.tar.gz" \
		"brotli-1.2.0.tar.gz" \
		"boringssl-${BORINGSSL_COMMIT}.zip" \
		"nghttp2-1.63.0.tar.bz2" \
		"ngtcp2-1.20.0.tar.bz2" \
		"nghttp3-1.15.0.tar.bz2" \
		"libunistring-1.1.tar.gz" \
		"libidn2-2.3.7.tar.gz"
	do
		ln -s "${DISTDIR}/${archive}" "${S}/${archive}" || die
	done
	ln -s "${DISTDIR}/curl-${CURL_VERSION}.tar.gz" \
		"${S}/curl-8_15_0.tar.gz" || die

	# The wrappers use no Bash-only syntax.
	sed -i '1s|.*|#!/bin/sh|' bin/curl_* || die

	# Pass Gentoo's libdir into the nested curl configure call.
	sed -i \
		's|config_flags="--prefix=@prefix@"|config_flags="--prefix=@prefix@ --libdir=@libdir@"|' \
		Makefile.in || die
}

src_configure() {
	econf \
		--with-ca-bundle="${EPREFIX}/etc/ssl/certs/ca-certificates.crt" \
		--with-ca-path="${EPREFIX}/etc/ssl/certs"
}

src_compile() {
	emake SUBJOBS="$(get_makeopts_jobs)" build
}

src_test() {
	emake SUBJOBS="$(get_makeopts_jobs)" checkbuild
}

src_install() {
	emake DESTDIR="${D}" install

	# The normal curl headers and development helpers would collide or point to
	# headers intentionally owned by net-misc/curl.
	rm -rf "${ED}/usr/include/curl" || die
	rm -f \
		"${ED}/usr/bin/curl-impersonate-config" \
		"${ED}/usr/$(get_libdir)/pkgconfig/libcurl-impersonate.pc" \
		"${ED}/usr/$(get_libdir)"/libcurl-impersonate.la \
		"${ED}/usr/$(get_libdir)"/libcurl-impersonate.a || die

	if ! use clients; then
		find "${ED}/usr/bin" -type f -name 'curl_*' -delete || die
	fi

	einstalldocs
}
