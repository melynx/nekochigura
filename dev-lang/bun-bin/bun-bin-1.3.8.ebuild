EAPI=8

DESCRIPTION="Incredibly fast JavaScript runtime, bundler, transpiler and package manager"
HOMEPAGE="https://bun.sh/"

SRC_URI="
	amd64? (
		elibc_glibc? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64.zip -> ${P}-x64.zip )
		elibc_musl? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64-musl.zip -> ${P}-x64-musl.zip )
	)
	arm64? (
		elibc_glibc? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64.zip -> ${P}-aarch64.zip )
		elibc_musl? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64-musl.zip -> ${P}-aarch64-musl.zip )
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+completions"

BDEPEND="app-arch/unzip"

RESTRICT="strip"

S="${WORKDIR}/bun-linux-${ARCH}"

QA_PREBUILT="usr/bin/bun"

src_unpack() {
	default

	# The zip extracts to a directory like bun-linux-x64 or bun-linux-aarch64
	# Find it and set S appropriately
	local extracted_dir
	extracted_dir=$(find "${WORKDIR}" -maxdepth 1 -type d -name "bun-linux-*" | head -n1)

	[[ -z "${extracted_dir}" ]] && die "Could not find extracted bun directory"
	S="${extracted_dir}"
}

src_install() {
	# Install the main bun binary
	dobin bun

	# Install bunx symlink (bun execute)
	dosym bun /usr/bin/bunx

	# Install completions for zsh and fish
	# Note: bash completions are not officially supported yet
	# See: https://github.com/oven-sh/bun/issues/671
	if use completions; then
		# Generate zsh completions
		SHELL=/usr/bin/zsh ./bun completions > "${T}"/_bun || die "Failed to generate zsh completions"
		insinto /usr/share/zsh/site-functions
		doins "${T}"/_bun

		# Generate fish completions
		SHELL=/usr/bin/fish ./bun completions > "${T}"/bun.fish || die "Failed to generate fish completions"
		insinto /usr/share/fish/vendor_completions.d
		doins "${T}"/bun.fish
	fi

	# Install README if it exists
	if [[ -f README.md ]]; then
		dodoc README.md
	fi
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
