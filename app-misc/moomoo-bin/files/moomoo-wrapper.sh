#!/bin/bash
export MOOMOO_HOME="/opt/moomoo"
export LD_LIBRARY_PATH="/opt/moomoo:/opt/moomoo/lib:/opt/moomoo/plugins/platforms:${LD_LIBRARY_PATH}"
# Include system Qt5 plugins for Wayland platform support
export QT_PLUGIN_PATH="/opt/moomoo/plugins:/usr/lib64/qt5/plugins:${QT_PLUGIN_PATH}"

# Enable native Wayland support to avoid blurry XWayland rendering
if [[ "${XDG_SESSION_TYPE}" == "wayland" || -n "${WAYLAND_DISPLAY}" ]]; then
	export QT_QPA_PLATFORM=wayland
	set -- --ozone-platform=wayland --enable-wayland-ime "$@"
fi

cd "/opt/moomoo"
exec "./moomoo" "$@"
