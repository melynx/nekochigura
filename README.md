# nekochigura Gentoo Overlay

My personal code basket — a place to stash scripts, configs, experiments, and anything else I am working on. Like its namesake (a nekochigura, a Japanese woven cat basket), it is cozy, a bit messy, and full of things I find useful.

## Installation

1. Add the overlay (direct from GitHub):
   ```sh
   sudo eselect repository add nekochigura git https://github.com/melynx/nekochigura.git
   sudo emaint sync -r nekochigura
   ```

2. Install packages as needed:
   ```sh
   sudo emerge -av media-video/ipu6-camera-meta
   ```

## Issues and requests

If you hit problems or need additional packages or tweaks, please open an issue on the repository.
