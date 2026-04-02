# Copyright 2026 czl
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

MY_PN="ghidra"
MY_PV="${PV}"
MY_DATE="20260303"

DESCRIPTION="Software reverse engineering framework developed by the NSA"
HOMEPAGE="https://ghidra-sre.org/ https://github.com/NationalSecurityAgency/ghidra"

SRC_URI="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${MY_PV}_build/${MY_PN}_${MY_PV}_PUBLIC_${MY_DATE}.zip"

S="${WORKDIR}/${MY_PN}_${MY_PV}_PUBLIC"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror strip"

BDEPEND="app-arch/unzip"

RDEPEND=">=virtual/jdk-21"

QA_PREBUILT="
	opt/ghidra/Ghidra/Features/*/os/linux_x86_64/*
	opt/ghidra/GPL/*/os/linux_x86_64/*
"

src_prepare() {
	default

	# Remove non-Linux platform files
	find . -type d -name "os" -exec sh -c '
		for dir; do
			for platform in mac_arm_64 mac_x86_64 win_x86_64 win_arm_64; do
				rm -rf "${dir}/${platform}"
			done
		done
	' _ {} +

	# Remove Windows batch files
	find . -name "*.bat" -delete
}

src_compile() {
	:
}

src_install() {
	insinto /opt/ghidra
	doins -r .

	# Make launch scripts executable
	local script
	for script in ghidraRun support/analyzeHeadless support/pyghidraRun \
		support/launch.sh support/sleighc_launcher.sh; do
		[[ -f "${ED}/opt/ghidra/${script}" ]] && fperms +x "/opt/ghidra/${script}"
	done

	# Make native binaries and shared libraries executable
	find "${ED}/opt/ghidra" -path "*/os/linux_x86_64/*" -type f -exec chmod +x {} +
	find "${ED}/opt/ghidra" -name "*.so" -type f -exec chmod +x {} +

	# Install wrapper script
	newbin "${FILESDIR}/ghidra-wrapper.sh" ghidra

	# Headless analysis wrapper
	newbin "${FILESDIR}/ghidra-headless-wrapper.sh" ghidra-analyzeHeadless

	# Desktop entry and icon
	domenu "${FILESDIR}/ghidra.desktop"
	newicon docs/images/GHIDRA_1.png ghidra.png
}

pkg_postinst() {
	elog "Ghidra has been installed to /opt/ghidra"
	elog ""
	elog "To launch the GUI, run: ghidra"
	elog "For headless analysis: ghidra-analyzeHeadless"
	elog ""
	elog "Ghidra requires JDK 21+. Set JAVA_HOME if needed."
	elog ""
	elog "For debugger/PyGhidra support, Python 3.9-3.13 is required."
	elog "Run: /opt/ghidra/support/pyghidraRun"
}
