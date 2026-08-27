# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Incredibly fast JavaScript runtime, bundler, transpiler and package manager"
HOMEPAGE="https://bun.sh/"
SRC_URI="
	amd64? (
		elibc_glibc? (
			https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64-baseline.zip
				-> ${P}-x64-baseline.zip
		)
		elibc_musl? (
			https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64-musl-baseline.zip
				-> ${P}-x64-musl-baseline.zip
		)
	)
	arm64? (
		elibc_glibc? (
			https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64.zip
				-> ${P}-aarch64.zip
		)
		elibc_musl? (
			https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64-musl.zip
				-> ${P}-aarch64-musl.zip
		)
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+completions"

BDEPEND="app-arch/unzip"

RESTRICT="strip"

QA_PREBUILT="usr/bin/bun"

src_unpack() {
	default

	if use amd64; then
		if use elibc_glibc; then
			S="${WORKDIR}/bun-linux-x64-baseline"
		else
			S="${WORKDIR}/bun-linux-x64-musl-baseline"
		fi
	elif use elibc_glibc; then
		S="${WORKDIR}/bun-linux-aarch64"
	else
		S="${WORKDIR}/bun-linux-aarch64-musl"
	fi

	[[ -d ${S} ]] || die "Could not find extracted Bun directory"
}

src_install() {
	dobin bun
	dosym bun /usr/bin/bunx

	if use completions; then
		SHELL=/usr/bin/zsh ./bun completions > "${T}"/_bun ||
			die "Failed to generate zsh completions"
		dozshcomp "${T}"/_bun

		SHELL=/usr/bin/fish ./bun completions > "${T}"/bun.fish ||
			die "Failed to generate fish completions"
		dofishcomp "${T}"/bun.fish
	fi

	[[ -f README.md ]] && dodoc README.md
}

pkg_postinst() {
	elog "Bun has been installed to /usr/bin/bun"
	elog ""
	elog "Bun is an incredibly fast JavaScript runtime, bundler,"
	elog "transpiler and package manager - all in one."
	elog ""
	elog "To get started:"
	elog "  bun init          - Initialize a new project"
	elog "  bun install       - Install dependencies"
	elog "  bun run <script>  - Run a script from package.json"
	elog "  bunx <package>    - Execute a package (like npx)"
	elog ""

	if use completions; then
		elog "Shell completions have been installed for:"
		elog "  - Zsh: /usr/share/zsh/site-functions/_bun"
		elog "  - Fish: /usr/share/fish/vendor_completions.d/bun.fish"
		elog ""
		elog "For zsh, make sure your fpath includes the site-functions directory."
		elog "For fish, completions should work automatically."
		elog ""
		elog "Note: Bash completions are not officially supported yet."
		elog "See: https://github.com/oven-sh/bun/issues/671"
		elog ""
	fi

	elog "For documentation, visit: https://bun.sh/docs"
}
