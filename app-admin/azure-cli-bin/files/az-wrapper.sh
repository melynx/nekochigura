#!/usr/bin/env bash
export AZ_INSTALLER=GENTOO
export PYTHONWARNINGS=ignore::SyntaxWarning
exec /opt/az/bin/python3.13 -Im azure.cli "$@"
