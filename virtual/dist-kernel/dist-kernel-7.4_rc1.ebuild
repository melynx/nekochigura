# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual to depend on any Distribution Kernel"
SLOT="0/${PVR}"
# A release candidate: machines opt in with package.accept_keywords "**".
KEYWORDS=""

# Shadows ::gentoo, whose virtual does not accept sys-kernel/yume-kernel.
RDEPEND="
	|| (
		~sys-kernel/yume-kernel-${PV}
		~sys-kernel/gentoo-kernel-${PV}
		~sys-kernel/gentoo-kernel-bin-${PV}
		~sys-kernel/vanilla-kernel-${PV%_p*}
		~sys-kernel/gentoo-kernel-modprep-${PV}
	)
"
