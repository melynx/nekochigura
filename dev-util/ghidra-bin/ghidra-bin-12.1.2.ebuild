# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

MY_PN="ghidra"
MY_PV="${PV}"
MY_DATE="20260605"

DESCRIPTION="Software reverse engineering framework developed by the NSA"
HOMEPAGE="https://ghidra-sre.org/ https://github.com/NationalSecurityAgency/ghidra"

SRC_URI="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${MY_PV}_build/${MY_PN}_${MY_PV}_PUBLIC_${MY_DATE}.zip"

S="${WORKDIR}/${MY_PN}_${MY_PV}_PUBLIC"

LICENSE="
	Apache-2.0 BSD BSD-2 CC-BY-2.5 CNRI-Jython Ghidra-CPP
	GPL-2+ GPL-2-with-classpath-exception GPL-3+ JDOM LGPL-2+ LGPL-2.1
	LGPL-2.1+ LGPL-3 MIT MPL-2.0 POSTGRESQL PSF-2 Unicode-3.0 ZLIB
	public-domain
"
SLOT="0"
KEYWORDS="amd64"

RESTRICT="strip"
REQUIRED_USE="elibc_glibc"

BDEPEND="app-arch/unzip"

RDEPEND="
	>=virtual/jdk-21
	sys-devel/gcc:*
"

QA_PREBUILT="
	opt/ghidra/Ghidra/Features/*/os/linux_x86_64/*
	opt/ghidra/Ghidra/Features/FileFormats/data/sevenzipnativelibs/Linux-amd64/*
	opt/ghidra/GPL/*/os/linux_x86_64/*
	opt/ghidra/docs/GhidraClass/ExerciseFiles/Advanced/*
"

src_prepare() {
	default

	# Remove non-Linux platform files
	find . -type d -name "os" -exec sh -c '
		set -e
		for dir; do
			for platform in mac_arm_64 mac_x86_64 win_x86_32 win_x86_64 win_arm_64; do
				rm -rf "${dir}/${platform}"
			done
		done
	' _ {} + || die
	rm -rf \
		Ghidra/Features/FileFormats/data/sevenzipnativelibs/Mac-x86_64 \
		Ghidra/Features/FileFormats/data/sevenzipnativelibs/Windows-amd64 || die

	# Remove Windows batch files
	find . -name "*.bat" -delete || die
}

src_compile() {
	:
}

src_install() {
	dodir /opt/ghidra
	cp -a . "${ED}/opt/ghidra/" || die
	fowners -R root:root /opt/ghidra
	find "${ED}/opt/ghidra" -type d -exec chmod 0755 {} + || die
	find "${ED}/opt/ghidra" -type f -exec chmod 0644 {} + || die

	local script
	for script in \
		ghidraRun \
		docker/build-docker-image.sh docker/entrypoint.sh \
		server/ghidraSvr server/jaas_external_program.example.sh \
		server/svrAdmin server/svrInstall server/svrUninstall \
		support/GhidraGo/ghidraGo support/analyzeHeadless support/bsim \
		support/bsim_ctl support/buildGhidraJar support/convertStorage \
		support/ghidraClean support/ghidraDebug support/gradle/gradlew \
		support/jshellRun support/launch.sh support/pyghidraRun support/sleigh \
		Ghidra/Debug/Debugger-isf/support/runISFServer \
		Ghidra/Features/BSim/support/make-postgres.sh; do
		chmod 0755 "${ED}/opt/ghidra/${script}" || die
	done

	find "${ED}/opt/ghidra/Ghidra/Debug" \
		-path "*/data/debugger-launchers/*" -type f \
		\( -name "*.sh" -o -name "*.jsh" \) -exec chmod 0755 {} + || die
	find \
		"${ED}/opt/ghidra/GPL/DemanglerGnu/os/linux_x86_64" \
		"${ED}/opt/ghidra/Ghidra/Features/Decompiler/os/linux_x86_64" \
		"${ED}/opt/ghidra/Ghidra/Features/FileFormats/os/linux_x86_64" \
		"${ED}/opt/ghidra/docs/GhidraClass/ExerciseFiles/Advanced" \
		-type f ! -name README.txt -exec chmod 0755 {} + || die

	newbin "${FILESDIR}/ghidra-wrapper.sh" ghidra
	newbin "${FILESDIR}/ghidra-headless-wrapper.sh" ghidra-analyzeHeadless

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
	elog "For debugger/PyGhidra support, Python 3.9-3.14 is required."
	elog "Run: /opt/ghidra/support/pyghidraRun"
}
