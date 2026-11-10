#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# pre-udev: unpack <ESP>/vendorfw/firmware.cpio into the initramfs (/vendorfw).
type info > /dev/null 2>&1 || . /lib/dracut-lib.sh

if [ -e /vendorfw ]; then
	info "yume-apple: vendor firmware already loaded by the bootloader"
	return 0 2> /dev/null || exit 0
fi
prop=/proc/device-tree/chosen/asahi,efi-system-partition
if [ ! -r "$prop" ]; then
	info "yume-apple: no ESP in the device tree; vendor firmware not loaded"
	return 0 2> /dev/null || exit 0
fi
uuid=$(tr -d '\000' < "$prop")

# udev is not running yet: load the NVMe driver and wait for the disk.
modprobe apple-mailbox
modprobe nvme-apple
disk=
i=0
while [ $i -lt 100 ]; do
	for disk in /sys/bus/platform/drivers/nvme-apple/*.nvme/nvme/nvme*/nvme*n1; do
		break
	done
	[ -e "$disk" ] && break
	sleep 0.1
	i=$((i + 1))
done
if [ ! -e "$disk" ]; then
	warn "yume-apple: timed out waiting for the NVMe disk; vendor firmware not loaded"
	return 0 2> /dev/null || exit 0
fi

esp=/run/yume-apple-esp
mkdir -p "$esp"
if ! mount -t vfat -o ro "PARTUUID=$uuid" "$esp"; then
	warn "yume-apple: cannot mount ESP $uuid; vendor firmware not loaded"
	return 0 2> /dev/null || exit 0
fi
if [ -s "$esp/vendorfw/firmware.cpio" ]; then
	(cd / && cpio --quiet -i < "$esp/vendorfw/firmware.cpio")
	info "yume-apple: vendor firmware unpacked"
elif [ -s "$esp/vendorfw.old/firmware.cpio" ]; then
	# apple-fwupdate stopped between its renames, or vendorfw is damaged:
	# the previous copy is better than none.
	(cd / && cpio --quiet -i < "$esp/vendorfw.old/firmware.cpio")
	warn "yume-apple: $esp/vendorfw/firmware.cpio is missing; unpacked vendorfw.old instead (rerun apple-fwupdate)"
else
	warn "yume-apple: $esp/vendorfw/firmware.cpio is missing; vendor firmware not loaded"
fi
umount "$esp"
