# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

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
REQUIRED_USE="elibc_glibc"

RDEPEND="
	app-arch/bzip2:0/1
	dev-libs/libffi:0/8
	dev-libs/openssl:0/3
	elibc_glibc? ( >=sys-libs/glibc-2.38 )
	sys-apps/util-linux
	virtual/zlib:0/1
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
"

BDEPEND="
	app-arch/gzip
	app-arch/zstd
	dev-util/patchelf
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

src_prepare() {
	default

	# Ubuntu uses a non-Gentoo bzip2 SONAME despite providing the same ABI.
	local bz2_module=( opt/az/lib/python*/lib-dynload/_bz2.*.so )
	[[ ${#bz2_module[@]} -eq 1 && -f ${bz2_module[0]} ]] ||
		die "Unable to locate the Python bzip2 module"
	patchelf --replace-needed libbz2.so.1.0 libbz2.so.1 \
		"${bz2_module[0]}" || die
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

	# Retain the documentation shipped with the Debian package.
	docinto debian
	dodoc usr/share/doc/azure-cli/copyright
	gzip -cd usr/share/doc/azure-cli/changelog.Debian.gz \
		> "${T}/changelog.Debian" || die
	dodoc "${T}/changelog.Debian"

	# Record the bundled Python distributions for future package audits.
	local inventory="${T}/bundled-packages.txt"
	local metadata
	local location
	local -a metadata_files=()
	mapfile -d '' -t metadata_files < <(
		find opt/az/lib/python*/site-packages \
			-path '*.dist-info/METADATA' -type f -print0 | sort -z
	)
	[[ ${#metadata_files[@]} -gt 0 ]] || die "No Python metadata found"
	{
		printf '%s\n' \
			"Bundled Python distributions shipped in Azure CLI ${PV}" \
			"Generated from the embedded .dist-info metadata." \
			"" \
			$'Name\tVersion\tDeclared license\tLocation'
		for metadata in "${metadata_files[@]}"; do
			location=${metadata%/METADATA}
			awk -v location="${location#opt/az/}" '
				BEGIN { FS = ": " }
				/^\r?$/ { exit }
				/^Name: / { name = substr($0, 7); sub(/\r$/, "", name) }
				/^Version: / { version = substr($0, 10); sub(/\r$/, "", version) }
				/^License: / { license = substr($0, 10); sub(/\r$/, "", license) }
				/^License-Expression: / {
					license = substr($0, 21); sub(/\r$/, "", license)
				}
				END {
					if (license == "")
						license = "UNKNOWN"
					printf "%s\t%s\t%s\t%s\n", \
						name, version, license, location
				}
			' "${metadata}" || die
		done
	} > "${inventory}" || die
	docinto .
	dodoc "${inventory}"
}

pkg_postinst() {
	elog "Azure CLI has been installed to /opt/az"
	elog "The 'az' command is available system-wide."
	elog ""
	elog "To get started, run: az login"
}
