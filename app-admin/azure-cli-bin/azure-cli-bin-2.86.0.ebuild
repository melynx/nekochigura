# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1

DESCRIPTION="Command-line interface for Microsoft Azure"
HOMEPAGE="https://github.com/Azure/azure-cli https://learn.microsoft.com/en-us/cli/azure/"

MY_PV="${PV}-1~noble"
SRC_URI="
	amd64? ( https://packages.microsoft.com/repos/azure-cli/pool/main/a/azure-cli/azure-cli_${MY_PV}_amd64.deb )
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-arch/bzip2
	dev-libs/libffi
	dev-libs/openssl
"

BDEPEND="
	app-arch/zstd
"

RESTRICT="bindist mirror strip"

QA_PREBUILT="opt/az/*"
QA_FLAGS_IGNORED="opt/az/*"

src_unpack() {
	local deb="${DISTDIR}/azure-cli_${MY_PV}_amd64.deb"
	mkdir -p "${S}" || die
	cd "${S}" || die
	ar x "${deb}" || die "Failed to extract .deb"
	tar --zstd -xf data.tar.zst || die "Failed to extract data archive"
}

src_install() {
	# Install the self-contained /opt/az directory
	insinto /opt/az
	doins -r opt/az/.

	# Restore executable permissions on binaries
	local f
	for f in "${ED}"/opt/az/bin/*; do
		[[ -f "${f}" ]] && fperms +x "/opt/az/bin/${f##*/}"
	done

	# Restore executable permissions on shared libraries
	find "${ED}/opt/az/lib" -name "*.so*" -type f -exec chmod +x {} + || die

	# Install wrapper script as /usr/bin/az
	newbin "${FILESDIR}/az-wrapper.sh" az

	# Install bash completion
	newbashcomp etc/bash_completion.d/azure-cli az
}

pkg_postinst() {
	elog "Azure CLI has been installed to /opt/az"
	elog "The 'az' command is available system-wide."
	elog ""
	elog "To get started, run: az login"
}
