#!/usr/bin/env python3
# Usage: aurora-fwextract SOURCE DEST
# SOURCE holds the installer's all_firmware.tar.gz and kernelcache; DEST receives
# firmware.cpio, firmware.tar and manifest.txt.
from asahi_firmware.update import main

main()
