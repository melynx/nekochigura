# SPDX-License-Identifier: GPL-2.0-only
# Locate and mount the system ESP that m1n1 names in the device tree.
# Sourced by update-m1n1 and apple-fwupdate (bash, not the initramfs).

ESP_DT_PROPERTY=/proc/device-tree/chosen/asahi,efi-system-partition
ESP_DIR=
ESP_MOUNTED_HERE=

esp_partuuid() {
	[[ -r ${ESP_DT_PROPERTY} ]] || return 1
	local uuid
	uuid=$(tr -d '\000' < "${ESP_DT_PROPERTY}")
	[[ ${uuid} =~ ^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$ ]] || return 1
	echo "${uuid,,}"
}

# Sets ESP_DIR to the mount point of the system ESP, mounting it if needed.
# Call it directly, not in $(...): esp_release needs ESP_MOUNTED_HERE from
# the calling shell.
esp_mount() {
	local uuid dev dir
	if uuid=$(esp_partuuid); then
		dev=/dev/disk/by-partuuid/${uuid}
		[[ -e ${dev} ]] || { echo "ESP ${uuid} has no device node" >&2; return 1; }
		dir=$(findmnt --noheadings --first-only --output TARGET --source "${dev}" 2>/dev/null) || dir=
		if [[ -z ${dir} ]]; then
			dir=/run/yume-apple-esp
			mkdir -p "${dir}"
			mount -t vfat "${dev}" "${dir}" || return 1
			ESP_MOUNTED_HERE=${dir}
		fi
	else
		# No m1n1 device tree (a chroot or builder): use a mounted ESP that holds m1n1.
		for dir in /boot/efi /boot; do
			[[ -d ${dir}/m1n1 ]] && break
			dir=
		done
		[[ -n ${dir} ]] || { echo "Cannot find the system ESP" >&2; return 1; }
		echo "No ESP in the device tree; using ${dir}" >&2
	fi
	ESP_DIR=${dir}
}

esp_release() {
	if [[ -n ${ESP_MOUNTED_HERE} ]]; then
		umount "${ESP_MOUNTED_HERE}" && ESP_MOUNTED_HERE=
	fi
}
