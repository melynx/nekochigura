# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="1Password password manager (beta channel)"
HOMEPAGE="https://1password.com/"

MY_PN="1password"
MY_PV="${PV/_beta/-}.BETA"
CLI_PV="2.35.0"

case ${ARCH} in
	amd64)
		MY_ARCH="x64"
		;;
	arm64)
		MY_ARCH="arm64"
		;;
esac

SRC_URI="
	amd64? (
		https://downloads.1password.com/linux/tar/beta/x86_64/${MY_PN}-${MY_PV}.x64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://downloads.1password.com/linux/tar/beta/aarch64/${MY_PN}-${MY_PV}.arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
	cli? (
		amd64? (
			https://cache.agilebits.com/dist/1P/op2/pkg/v${CLI_PV}/op_linux_amd64_v${CLI_PV}.zip
				-> op-${CLI_PV}-amd64.zip
		)
		arm64? (
			https://cache.agilebits.com/dist/1P/op2/pkg/v${CLI_PV}/op_linux_arm64_v${CLI_PV}.zip
				-> op-${CLI_PV}-arm64.zip
		)
	)
"

S="${WORKDIR}/${MY_PN}-${MY_PV}.${MY_ARCH}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+cli +policykit"

RESTRICT="bindist mirror strip"

BDEPEND="
	acct-group/onepassword
	acct-group/onepassword-mcp
	cli? (
		acct-group/onepassword-cli
		app-arch/unzip
	)
"
RDEPEND="
	!!app-admin/1password-bin
	!!gui-apps/1password
	acct-group/onepassword
	acct-group/onepassword-mcp
	x11-misc/xdg-utils
	cli? (
		!!app-misc/1password-cli
		acct-group/onepassword-cli
	)
	policykit? ( sys-auth/polkit )
"

# All binaries are proprietary and cannot be stripped or rebuilt.
QA_PREBUILT="
	opt/1Password/*
	usr/bin/op
"
QA_FLAGS_IGNORED="
	opt/1Password/*
	usr/bin/op
"

src_install() {
	dodir /opt/1Password
	cp -a . "${ED}/opt/1Password/" || die "Failed to install 1Password"
	rm "${ED}"/opt/1Password/{after-install.sh,after-remove.sh,install.sh} || die

	dosym ../../opt/1Password/1password /usr/bin/1password
	dosym ../../opt/1Password/op-ssh-sign /usr/bin/op-ssh-sign
	dosym ../../opt/1Password/1password-mcp /usr/bin/1password-mcp
	dosym 1password-mcp /opt/1Password/onepassword-mcp

	fperms 4755 /opt/1Password/chrome-sandbox
	fowners root:onepassword /opt/1Password/1Password-BrowserSupport
	fperms 2755 /opt/1Password/1Password-BrowserSupport
	fowners root:onepassword-mcp /opt/1Password/1password-mcp
	fperms 2755 /opt/1Password/1password-mcp

	if use cli; then
		dobin "${WORKDIR}/op"
		fowners root:onepassword-cli /usr/bin/op
		fperms 2755 /usr/bin/op
	fi

	domenu resources/1password.desktop
	local size
	for size in 32 64 256 512; do
		doicon -s ${size} "resources/icons/hicolor/${size}x${size}/apps/1password.png"
	done

	insinto /etc/1password
	doins resources/custom_allowed_browsers
	docinto examples
	dodoc resources/custom_allowed_browsers

	rm "${ED}/opt/1Password/resources/1password.desktop" || die
	rm "${ED}/opt/1Password/resources/custom_allowed_browsers" || die
	rm -r "${ED}/opt/1Password/resources/icons" || die

	if ! use policykit; then
		rm "${ED}/opt/1Password/com.1password.1Password.policy.tpl" || die
	fi
}

pkg_preinst() {
	xdg_pkg_preinst

	if use policykit; then
		local policy_owners
		policy_owners="$(
			cut -d: -f1,3 "${EROOT}/etc/passwd" |
				grep -E ':[0-9]{4}$' |
				cut -d: -f1 |
				head -n 10 |
				sed 's/^/unix-user:/' |
				tr '\n' ' '
		)"

		mkdir -p "${ED}/usr/share/polkit-1/actions" || die
		sed -e "s/\${POLICY_OWNERS}/${policy_owners}/" \
			"${ED}/opt/1Password/com.1password.1Password.policy.tpl" \
			> "${ED}/usr/share/polkit-1/actions/com.1password.1Password.policy" || die
		rm "${ED}/opt/1Password/com.1password.1Password.policy.tpl" || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "1Password beta has been installed to /opt/1Password."
	elog "Ignore in-app updates and use Portage to update this package."
	if use cli; then
		elog "1Password CLI has been installed to /usr/bin/op."
	fi
	ewarn "This is proprietary software; redistribution is not permitted."
}
