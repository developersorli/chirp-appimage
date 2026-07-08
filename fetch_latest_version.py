#!/usr/bin/env python3
"""Fetch the latest CHIRP version from archive.chirpmyradio.com"""
import sys
import re
import urllib.request

url = "https://archive.chirpmyradio.com/chirp_next/"
req = urllib.request.Request(url, headers={"User-Agent": "goldstar611"})
try:
    with urllib.request.urlopen(req) as response:
        html = response.read().decode("utf-8")
except Exception as e:
    print(f"Error fetching {url}: {e}", file=sys.stderr)
    sys.exit(1)

matches = re.findall(r'href="(next-\d+/)"', html)
if matches:
    print(sorted(matches)[-1].rstrip("/"))
else:
    print("", end="")
