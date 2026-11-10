#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Drivers an Apple Silicon Mac needs before the real root: storage, SMC,
# USB-C, the internal keyboard and trackpad, and the display outputs.

check() {
	return 0
}

installkernel() {
	# NVMe and the SMC
	hostonly='' instmods apple-mailbox nvme-apple macsmc
	# USB-C ports and their controllers
	hostonly='' instmods pinctrl-apple-gpio i2c-pasemi-platform tps6598x \
		apple-dart dwc3 dwc3-of-simple nvmem-apple-efuses phy-apple-atc \
		xhci-plat-hcd xhci-pci pcie-apple gpio-macsmc
	# Real-time clock
	hostonly='' instmods rtc-macsmc spmi-apple-controller
	# Internal keyboard and trackpad (SPI on M1/M2, DockChannel on later Macs)
	hostonly='' instmods spi-apple spi-hid-apple spi-hid-apple-of \
		apple-dockchannel dockchannel-hid apple-rtkit-helper
	# DisplayPort/HDMI audio and display outputs
	hostonly='' instmods apple-sio mux-apple-display-crossbar phy-apple-dptx
}
