#!/bin/bash
set -xe

rm -f Chirp-*-*.AppImage

# Download the latest CHIRP wheel from archive.chirpmyradio.com
LATEST_DIR=$(python3 ./fetch_latest_version.py)
echo "Latest version directory: ${LATEST_DIR}"

# Extract version number from directory name (e.g., next-20260612 -> 20260612)
CHIRP_VERSION=${LATEST_DIR#next-}
echo "CHIRP version: ${CHIRP_VERSION}"

# Download the wheel using Python (more reliable than curl on GitHub Actions)
python3 ./fetch_latest_version.py --download "${LATEST_DIR}"

export CHIRP_VERSION="${LATEST_DIR}"

# x86_64 (64-bit Intel/AMD)
export TARGET_ARCH_APT=amd64
export TARGET_ARCH_APPIMAGE=x86_64
export SOURCE_LINE_1="deb [arch=${TARGET_ARCH_APT}] http://archive.ubuntu.com/ubuntu jammy main universe"
export KEY_URL_1="http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C"
appimage-builder --recipe AppImageBuilder.yml
