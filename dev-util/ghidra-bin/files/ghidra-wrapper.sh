#!/usr/bin/env bash
# Needed for non-reparenting window managers (tiling WMs)
export _JAVA_AWT_WM_NONREPARENTING=1
exec /opt/ghidra/ghidraRun "$@"
