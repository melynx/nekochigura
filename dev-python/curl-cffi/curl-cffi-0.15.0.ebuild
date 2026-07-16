# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_EXT=1

inherit distutils-r1 pypi

DESCRIPTION="Python bindings for curl-impersonate via CFFI"
HOMEPAGE="
	https://github.com/lexiforest/curl_cffi/
	https://pypi.org/project/curl-cffi/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=net-misc/curl-impersonate-1.5.2:="
RDEPEND="
	${DEPEND}
	>=dev-python/certifi-2024.2.2[${PYTHON_USEDEP}]
	>=dev-python/cffi-2.0.0:=[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
"
BDEPEND=">=dev-python/cffi-2.0.0[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}/${P}-system-libs.patch" )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	rm -rf curl_cffi || die

	epytest -c /dev/null -p no:cacheprovider --noconftest \
		tests/unittest/test_cookies.py \
		tests/unittest/test_headers.py \
		tests/unittest/cli/test_doctor.py \
		tests/unittest/cli/test_output.py \
		tests/unittest/cli/test_parse.py \
		tests/unittest/cli/test_request.py::test_cli_no_args_shows_help
}
