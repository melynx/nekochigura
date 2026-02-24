# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the MIT License

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

RDEPEND="
	gui-wm/hyprland
	sys-apps/dbus
"

src_unpack() {
	default
	mv "${WORKDIR}/vendor" "${S}/vendor" || die
}

src_compile() {
	ego build \
		-ldflags "-s -w \
			-X github.com/fiffeek/hyprdynamicmonitors/cmd.Version=${PV} \
			-X github.com/fiffeek/hyprdynamicmonitors/cmd.Commit=gentoo \
			-X github.com/fiffeek/hyprdynamicmonitors/cmd.BuildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
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
