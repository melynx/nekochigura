#!/bin/bash
export MOOMOO_HOME="/opt/moomoo"
export LD_LIBRARY_PATH="/opt/moomoo:/opt/moomoo/lib:/opt/moomoo/plugins/platforms:${LD_LIBRARY_PATH}"
# Moomoo ships a private Qt5 runtime and only its matching XCB platform
# plugin. Do not mix in system Qt plugins; Qt QPA plugins must match the
# exact Qt runtime that loads them. On a Wayland desktop this runs through
# XWayland.
export QT_PLUGIN_PATH="/opt/moomoo/plugins:/opt/moomoo/plugins/platforms"
export QT_QPA_PLATFORM=xcb

cd "/opt/moomoo"
exec "./moomoo" "$@"
