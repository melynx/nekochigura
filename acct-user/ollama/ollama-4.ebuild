# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for Ollama"
ACCT_USER_ID=-1
ACCT_USER_HOME=/var/lib/ollama
ACCT_USER_HOME_PERMS=0750
ACCT_USER_GROUPS=( ollama )

KEYWORDS="amd64"
IUSE="cuda rocm vulkan"

acct-user_add_deps

RDEPEND+="
	cuda? (
		acct-group/render
		acct-group/video
	)
	rocm? (
		acct-group/render
		acct-group/video
	)
	vulkan? (
		acct-group/render
		acct-group/video
	)
"

pkg_setup() {
	# sci-ml/ollama[cuda,rocm,vulkan]
	if use cuda || use rocm || use vulkan; then
		ACCT_USER_GROUPS+=( render video )
	fi
}
