#!/usr/bin/env python3
"""Fetch the latest CHIRP version and download the wheel from archive.chirpmyradio.com"""
import sys
import re
import os
import urllib.request

BASE_URL = "https://archive.chirpmyradio.com/chirp_next/"
HEADERS = {"User-Agent": "goldstar611"}


def fetch_url(url):
    """Fetch a URL and return the response content."""
    req = urllib.request.Request(url, headers=HEADERS)
    try:
        with urllib.request.urlopen(req) as response:
            return response.read()
    except Exception as e:
        print(f"Error fetching {url}: {e}", file=sys.stderr)
        sys.exit(1)


def get_latest_version():
    """Get the latest CHIRP version directory name."""
    html = fetch_url(BASE_URL).decode("utf-8")
    matches = re.findall(r'href="(next-\d+/)"', html)
    if matches:
        return sorted(matches)[-1].rstrip("/")
    print("No version found!", file=sys.stderr)
    sys.exit(1)


def download_wheel(version_dir):
    """Download the CHIRP wheel for the given version."""
    version = version_dir.replace("next-", "")
    wheel_url = f"{BASE_URL}{version_dir}/chirp-{version}-py3-none-any.whl"
    wheel_name = f"chirp-{version}-py3-none-any.whl"

    print(f"Downloading from: {wheel_url}", file=sys.stderr)
    data = fetch_url(wheel_url)

    with open(wheel_name, "wb") as f:
        f.write(data)

    size_kb = len(data) / 1024
    print(f"Downloaded {wheel_name} ({size_kb:.0f} KB)", file=sys.stderr)
    return wheel_name


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "--download":
        download_wheel(sys.argv[2])
    else:
        version_dir = get_latest_version()
        print(version_dir)
