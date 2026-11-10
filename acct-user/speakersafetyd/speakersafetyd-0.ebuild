# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for the speaker protection daemon"
# The ID the Mac already uses.
ACCT_USER_ID=547
ACCT_USER_GROUPS=( audio speakersafetyd )

acct-user_add_deps
