# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to depend on any Distribution Kernel"
SLOT="0/${PVR}"
KEYWORDS="~amd64 ~arm64"

# Gentoo does not yet ship another 7.3 distribution-kernel provider.
RDEPEND="~sys-kernel/yume-kernel-${PV}"
