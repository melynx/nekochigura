#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Load the Apple vendor firmware (Wi-Fi, Bluetooth, ...) from the system ESP
# early in the initramfs, then hand it to the real root at /lib/firmware/vendor.

check() {
	# Host-only images include this only on an Apple Silicon Mac booted by m1n1.
	if [[ -n ${hostonly} && ! -e /proc/device-tree/chosen/asahi,efi-system-partition ]]; then
		return 255
	fi
	return 0
}

depends() {
	echo fs-lib
}

installkernel() {
	hostonly='' instmods apple-mailbox nvme-apple vfat nls_cp437 nls_iso8859-1
}

install() {
	inst_dir /lib/firmware
	ln_r /vendorfw /lib/firmware/vendor
	inst_multiple cpio mkdir modprobe mount umount sleep tr
	inst_hook pre-udev 10 "${moddir}/load-vendorfw.sh"
	inst_hook cleanup 99 "${moddir}/install-vendorfw.sh"
}
