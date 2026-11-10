# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd udev

DESCRIPTION="Apple Silicon boot integration: m1n1 stage 2, vendor firmware, battery limit, SEP"
HOMEPAGE="https://github.com/melynx/nekochigura"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm64"

RDEPEND="
	app-arch/cpio
	app-arch/gzip
	sys-apps/util-linux
	sys-firmware/aurora-fwextract
	sys-kernel/dracut
	!sys-apps/asahi-scripts
"

src_install() {
	dobin "${FILESDIR}"/update-m1n1 "${FILESDIR}"/apple-fwupdate
	insinto /usr/lib/${PN}
	doins "${FILESDIR}"/esp.sh

	exeinto /usr/lib/kernel/install.d
	doexe "${FILESDIR}"/99-update-m1n1.install

	local mod
	for mod in 90yume-apple-vendorfw 91yume-apple-modules; do
		exeinto /usr/lib/dracut/modules.d/${mod}
		doexe "${FILESDIR}"/dracut/${mod}/*.sh
	done
	insinto /usr/lib/dracut/dracut.conf.d
	doins "${FILESDIR}"/{10-yume-apple,20-yume-apple-sep}.conf

	# The real root mounts the vendor firmware tmpfs here.
	keepdir /lib/firmware/vendor

	udev_dorules "${FILESDIR}"/93-yume-apple-battery.rules
	systemd_dounit "${FILESDIR}"/yume-apple-battery-save.{path,service}

	# The Secure Enclave driver, read-only, loaded from the real root.
	systemd_dounit "${FILESDIR}"/apple-sep.{path,service}
	insinto /lib/modprobe.d
	doins "${FILESDIR}"/yume-apple-sep.conf

	docinto examples
	dodoc "${FILESDIR}"/update-m1n1.example
}

pkg_postinst() {
	udev_reload
	# udev adds SYSTEMD_WANTS only when the battery device appears.
	elog "The saved battery charge limit is kept from the next boot. To keep"
	elog "saving changes before then, run: systemctl start yume-apple-battery-save.path"
	elog "update-m1n1 reads /etc/default/update-m1n1 (example in /usr/share/doc/${PF}/examples)."
	elog "apple-fwupdate re-extracts <ESP>/vendorfw from the installer's copy, kept in"
	elog "<ESP>/apple-firmware (the installer writes it to <ESP>/asahi; move it there)."
	elog "The built-in microphones need the SEP driver. To load it, read-only, at boot:"
	elog "  systemctl enable apple-sep.path"
	elog "Remove any other modprobe.d file with apple_sep options: given twice, they"
	elog "stop the module from loading."
}

pkg_postrm() {
	udev_reload
}
