#!/bin/bash
set -xe

rm -f Chirp-*-*.AppImage

# Because Cloudflare...
#ver_with_next=$(basename $(curl -H "User-Agent: goldstar611" -L -s -o /dev/null -w '%{url_effective}' "https://archive.chirpmyradio.com/download?stream=next"))
#ver_without_next=${ver_with_next//next-/}
#curl -H "User-Agent: goldstar611" -o chirp-${ver_without_next}-py3-none-any.whl https://archive.chirpmyradio.com/chirp_next/${ver_with_next}/chirp-${ver_without_next}-py3-none-any.whl

# Download directly from chirpmyradio.com instead of broken S3 bucket
CHIRP_VERSION=$(curl -s -L -H "User-Agent: goldstar611" -I "https://archive.chirpmyradio.com/download?stream=next" 2>&1 | grep -i location | head -1 | grep -oE '[0-9]{8}')
export CHIRP_VERSION
wget -q --header="User-Agent: goldstar611" "https://archive.chirpmyradio.com/chirp_next/next-${CHIRP_VERSION}/chirp-${CHIRP_VERSION}-py3-none-any.whl"

# x86_64 (64-bit Intel/AMD)
export TARGET_ARCH_APT=amd64
export TARGET_ARCH_APPIMAGE=x86_64
export SOURCE_LINE_1="deb [arch=${TARGET_ARCH_APT}] http://archive.ubuntu.com/ubuntu jammy main universe"
export KEY_URL_1="http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C"
appimage-builder --recipe AppImageBuilder.yml

# armhf (32-bit ARM)
export TARGET_ARCH_APT=armhf
export TARGET_ARCH_APPIMAGE=armhf
export SOURCE_LINE_1="deb [arch=${TARGET_ARCH_APT}] http://ports.ubuntu.com/ubuntu-ports jammy main universe"
export KEY_URL_1="http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C"
appimage-builder --recipe AppImageBuilder.yml

# arm64/aarch64 (64-bit ARM)
export TARGET_ARCH_APT=arm64
export TARGET_ARCH_APPIMAGE=aarch64
export SOURCE_LINE_1="deb [arch=${TARGET_ARCH_APT}] http://ports.ubuntu.com/ubuntu-ports jammy main universe"
export KEY_URL_1="http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C"
appimage-builder --recipe AppImageBuilder.yml

