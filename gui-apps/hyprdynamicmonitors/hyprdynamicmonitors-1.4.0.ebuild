# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd shell-completion

DESCRIPTION="Event-driven dynamic monitor configuration manager for Hyprland"
HOMEPAGE="https://github.com/fiffeek/hyprdynamicmonitors"
SRC_URI="
	https://github.com/fiffeek/hyprdynamicmonitors/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://raw.githubusercontent.com/melynx/nekochigura-dependencies/master/gui-apps/${PN}/${P}-vendor.tar.xz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bash-completion fish-completion zsh-completion"

BDEPEND=">=dev-lang/go-1.25.0"
RDEPEND="
	gui-wm/hyprland
	sys-apps/dbus
"

src_unpack() {
	default
	mv "${WORKDIR}/vendor" "${S}/vendor" || die
}

src_configure() {
	go-module_src_configure
}

src_compile() {
	ego build \
		-trimpath \
		-ldflags "\
			-X github.com/fiffeek/hyprdynamicmonitors/cmd.Version=${PV} \
			-X github.com/fiffeek/hyprdynamicmonitors/cmd.Commit=693e68b \
			-X github.com/fiffeek/hyprdynamicmonitors/cmd.BuildDate=2025-12-01T15:10:38Z" \
		-o "${PN}" .
}

src_install() {
	dobin "${PN}"

	insinto /usr/share/${PN}/themes
	doins -r themes/*

	systemd_douserunit infrastructure/systemd/${PN}.service
	systemd_douserunit infrastructure/systemd/${PN}-prepare.service

	if use bash-completion; then
		"${S}/${PN}" completion bash > ${PN}.bash || die
		newbashcomp ${PN}.bash ${PN}
	fi

	if use zsh-completion; then
		"${S}/${PN}" completion zsh > ${PN}.zsh || die
		newzshcomp ${PN}.zsh _${PN}
	fi

	if use fish-completion; then
		"${S}/${PN}" completion fish > ${PN}.fish || die
		newfishcomp ${PN}.fish ${PN}.fish
	fi
}
