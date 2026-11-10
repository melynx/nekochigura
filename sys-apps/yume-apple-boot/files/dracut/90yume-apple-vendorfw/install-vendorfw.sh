#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# cleanup: give the unpacked firmware to the real root on a tmpfs.
type info > /dev/null 2>&1 || . /lib/dracut-lib.sh

[ -e /vendorfw/.vendorfw.manifest ] || return 0 2> /dev/null || exit 0
if [ ! -d /sysroot/lib/firmware/vendor ]; then
	warn "yume-apple: /lib/firmware/vendor is missing on the root filesystem"
	return 0 2> /dev/null || exit 0
fi
mount -t tmpfs -o mode=0755 vendorfw /sysroot/lib/firmware/vendor
cp -a /vendorfw/. /sysroot/lib/firmware/vendor/
