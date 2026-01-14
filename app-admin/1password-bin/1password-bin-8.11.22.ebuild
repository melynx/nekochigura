EAPI=8

inherit desktop xdg

DESCRIPTION="1Password password manager"
HOMEPAGE="https://1password.com/"

MY_PN="${PN/-bin/}"
CLI_PV="2.32.0"

SRC_URI="
	amd64? ( https://downloads.1password.com/linux/tar/stable/x86_64/${MY_PN}-${PV}.x64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://downloads.1password.com/linux/tar/stable/aarch64/${MY_PN}-${PV}.arm64.tar.gz -> ${P}-arm64.tar.gz )
	cli? (
		amd64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${CLI_PV}/op_linux_amd64_v${CLI_PV}.zip -> op-${CLI_PV}-amd64.zip )
		arm64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${CLI_PV}/op_linux_arm64_v${CLI_PV}.zip -> op-${CLI_PV}-arm64.zip )
	)
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+policykit +cli"

RESTRICT="bindist mirror strip"

BDEPEND="
	cli? ( app-arch/unzip )
"

RDEPEND="
	acct-group/onepassword-cli
	x11-misc/xdg-utils
	policykit? ( sys-auth/polkit )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

# All binaries are proprietary and cannot be stripped
QA_PREBUILT="
	opt/1Password/*
	usr/bin/op
"
QA_FLAGS_IGNORED="
	opt/1Password/*
	usr/bin/op
"
QA_EXECSTACK="opt/1Password/chrome-sandbox"

src_unpack() {
	default

	# The tarball extracts to a versioned directory - find it and set S
	local extracted_dir
	extracted_dir=$(find "${WORKDIR}" -maxdepth 1 -type d -name "${MY_PN}-*" | head -n1)

	[[ -z "${extracted_dir}" ]] && die "Could not find extracted 1Password directory"
	S="${extracted_dir}"
}

src_install() {
	# Install everything to /opt/1Password
	insinto /opt/1Password
	doins -r .

	# Make binaries executable
	fperms +x /opt/1Password/${MY_PN}
	fperms +x /opt/1Password/1Password-BrowserSupport
	fperms +x /opt/1Password/chrome-sandbox
	fperms +x /opt/1Password/chrome_crashpad_handler
	fperms +x /opt/1Password/op-ssh-sign
	fperms +x /opt/1Password/1Password-LastPass-Exporter

	# Symlink main executable to /usr/bin
	dosym ../../opt/1Password/${MY_PN} /usr/bin/${MY_PN}

	# Symlink SSH agent helper
	dosym ../../opt/1Password/op-ssh-sign /usr/bin/op-ssh-sign

	# Install 1Password CLI if USE flag enabled
	if use cli; then
		dobin "${WORKDIR}"/op
		fowners root:onepassword-cli /usr/bin/op
		fperms 2755 /usr/bin/op
	fi

	# Install icons
	if [[ -d resources/icons ]]; then
		for size in 32 64 128 256 512; do
			if [[ -f "resources/icons/hicolor/${size}x${size}/apps/${MY_PN}.png" ]]; then
				doicon -s ${size} "resources/icons/hicolor/${size}x${size}/apps/${MY_PN}.png"
			fi
		done
	fi

	# Install desktop file
	domenu "${FILESDIR}/${MY_PN}.desktop"

	# Install PolicyKit policy if enabled
	if use policykit; then
		insinto /usr/share/polkit-1/actions
		doins "${FILESDIR}/${MY_PN}-polkit.policy"
	fi

	# Documentation
	if [[ -d resources ]]; then
		dodoc -r resources/
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	# Set chrome-sandbox setuid (required for sandboxing)
	chmod 4755 "${EROOT}/opt/1Password/chrome-sandbox" || die "Failed to set setuid on chrome-sandbox"

	# Set BrowserSupport group ownership (required for browser integration)
	chgrp onepassword-cli "${EROOT}/opt/1Password/1Password-BrowserSupport" || die "Failed to set group on BrowserSupport"
	chmod 2755 "${EROOT}/opt/1Password/1Password-BrowserSupport" || die "Failed to set permissions on BrowserSupport"

	elog "1Password has been installed to /opt/1Password"
	elog ""
	elog "To use 1Password:"
	elog "  1. Launch 1Password from your application menu"
	elog "  2. Sign in with your account"
	elog ""

	if use policykit; then
		elog "PolicyKit integration enabled for system authentication."
		elog ""
	fi

	elog "For browser integration:"
	elog "  Install the 1Password browser extension for your browser."
	elog "  The desktop app will automatically connect to the extension."
	elog ""
	elog "SSH agent integration (op-ssh-sign) has been installed."
	elog "Configure your SSH client to use 1Password for SSH key management."
	elog ""

	if use cli; then
		elog "1Password CLI (op) has been installed to /usr/bin/op"
		elog ""
		elog "To use the CLI with the desktop app:"
		elog "  1. Open 1Password desktop app"
		elog "  2. Go to Settings > Developer"
		elog "  3. Enable 'Integrate with 1Password CLI'"
		elog ""
		elog "The CLI will authenticate through the desktop app."
		elog "No manual group membership is required."
		elog ""
		elog "For more information:"
		elog "  https://developer.1password.com/docs/cli/app-integration"
		elog ""
	fi

	ewarn "This is proprietary software with an all-rights-reserved license."
	ewarn "Redistribution is not permitted."
	ewarn ""
	ewarn "1Password may show update notifications."
	ewarn "Please ignore them and use Portage to update the package."
}
