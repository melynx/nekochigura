# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-group

# 1Password intentionally uses a regular-range group for peer authentication.
ACCT_GROUP_ID=1562
ACCT_GROUP_ENFORCE_ID=yes

pkg_pretend() {
	acct-group_pkg_pretend

	local group_id=${ACCT_GROUP_ONEPASSWORD_MCP_ID:-${ACCT_GROUP_ID}}
	(( group_id >= 1000 )) || die "onepassword-mcp requires a GID of at least 1000"
}
