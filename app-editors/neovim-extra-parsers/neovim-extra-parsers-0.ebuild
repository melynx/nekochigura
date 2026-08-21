# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Tree-sitter parsers on Neovim's runtimepath that app-editors/neovim omits"
HOMEPAGE="https://github.com/neovim/neovim"
S="${WORKDIR}"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream Neovim builds markdown_inline from the same tree-sitter-markdown
# tarball as the block grammar -- see cmake.deps/cmake/MarkdownParserCMakeLists.txt,
# which declares both modules and installs both to lib/nvim/parser. Gentoo split
# that tarball into two packages (dev-libs/tree-sitter-markdown narrows S= to the
# block subdir), and app-editors/neovim depends on and symlinks only the first.
# The markdown_inline *queries* do ship in the runtime tree, so the parser looks
# installed until something actually asks for an inline injection.
#
# html is not an upstream parser; it is here because render-markdown.nvim uses it
# for inline HTML, and having it saves a second package for one symlink.
RDEPEND="
	app-editors/neovim
	=dev-libs/tree-sitter-markdown-inline-0.5*
	dev-libs/tree-sitter-html
"

src_install() {
	# site/parser/, not runtime/parser/: the latter is owned by app-editors/neovim
	# and installing there would be a file collision. Both are on runtimepath.
	dodir /usr/share/nvim/site/parser
	local p
	for p in markdown-inline html; do
		# Package names use '-', tree-sitter language names use '_'. Neovim
		# dlopens parser/<lang>.so and looks up the symbol tree_sitter_<lang>,
		# so the filename has to match the language, not the package.
		dosym -r "/usr/$(get_libdir)/libtree-sitter-${p}.so" \
			"/usr/share/nvim/site/parser/${p//-/_}.so"
	done
}
