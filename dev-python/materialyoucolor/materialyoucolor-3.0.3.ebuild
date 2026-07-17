# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Material You color algorithms for python!"
HOMEPAGE="https://github.com/T-Dynamos/materialyoucolor-python"

LICENSE="MIT"
SLOT="0"

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/T-Dynamos/materialyoucolor-python.git"
else
	SRC_URI="https://github.com/T-Dynamos/materialyoucolor-python/releases/download/v${PV}/${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

RDEPEND="dev-python/pillow[${PYTHON_USEDEP}]"
BDEPEND="
	>=dev-python/pybind11-2.11.0[${PYTHON_USEDEP}]
	test? (
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
	)
"
PATCHES=( "${FILESDIR}/${PN}-fix-theme-utils-import.patch" )

distutils_enable_tests unittest

python_test() {
	cd "${T}" || die
	local -x PYTHONPATH="${BUILD_DIR}/install$(python_get_sitedir)"
	"${EPYTHON}" -c \
		'import importlib, pkgutil, materialyoucolor;
[importlib.import_module(x.name) for x in pkgutil.walk_packages(materialyoucolor.__path__, "materialyoucolor.")]' || die
	"${EPYTHON}" "${S}/tests/test_all.py" >/dev/null || die
}
