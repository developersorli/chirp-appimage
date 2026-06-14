# Build Report - CHIRP AppImage

## Overview

This document describes the changes and fixes applied to successfully build the CHIRP AppImage on **Zorin OS 18.1** (based on Ubuntu 24.04, Python 3.12).

**Build result:** `Chirp-next-20260612-x86_64.AppImage` (67 MB)

---

## Issues Fixed

### 1. Backblaze B2 Credentials Expired

**Problem:** The original `build.sh` script used `chirp_mirror_dl.py` which downloads the CHIRP wheel from Backblaze B2 cloud storage. The access credentials (`0058b2a3056cdad0000000002` / `K005TuW2ByjRCxqZEcjEOSFa+C72t/A`) have expired, causing the download to fail.

**Solution:** Created `build_local.sh` which downloads the CHIRP wheel directly from the official mirror at `archive.chirpmyradio.com` using `curl`. The script:
- Fetches the directory listing to find the latest version
- Extracts the version number from the directory name
- Downloads the `.whl` file directly

### 2. PEP 668 - Externally Managed Environment

**Problem:** Ubuntu 24.04 enforces PEP 668, which prevents `pip install` from running outside a virtual environment. The error message was:
```
error: externally-managed-environment
```

**Solution:** Created a Python virtual environment (`venv/`) and installed `appimage-builder` inside it.

### 3. `comp: zstd` Not Supported in appimage-builder 1.1.0

**Problem:** The `AppImageBuilder.yml` contained `comp: zstd` under the `AppImage` section, which is not supported by appimage-builder version 1.1.0.

**Solution:** Removed the `comp: zstd` line from `AppImageBuilder.yml`.

### 4. packaging Library Bug - InvalidVersion Exception

**Problem:** The `packaging` library (used by appimage-builder) throws an `InvalidVersion` exception when parsing certain Debian package versions like `1.21.1ubuntu2`. This caused the build to crash when comparing package versions in `Package.__gt__()`.

**File modified:** `venv/lib/python3.12/site-packages/appimagebuilder/modules/deploy/apt/package.py`

**Solution:** Added a try/catch block in the `__gt__` method to handle `InvalidVersion` exceptions gracefully:

```python
def __gt__(self, other):
    if isinstance(other, Package):
        try:
            return version.parse(self.version) > version.parse(other.version)
        except version.InvalidVersion:
            return False
```

### 5. Incorrect Python Path for chirp.png Icon

**Problem:** The `AppImageBuilder.yml` referenced the chirp icon at `AppDir/usr/local/lib/python3.10/dist-packages/chirp/share/chirp.png`, but the actual path on Ubuntu 24.04 with Python 3.12 is `AppDir/usr/lib/python3.12/site-packages/chirp/share/chirp.png`.

**Solution:** Updated the path in `AppImageBuilder.yml`:
```yaml
cp AppDir/usr/lib/python3.12/site-packages/chirp/share/chirp.png AppDir/usr/share/icons/
```

### 6. Missing System Dependencies

**Problem:** The build failed because `appimagetool` and `patchelf` were not installed on the system.

**Solution:** Installed the required tools:
```bash
sudo apt install patchelf
# appimagetool was downloaded from GitHub releases
```

### 7. Incorrect `exec_args` Path for chirp Script

**Problem:** The `AppImageBuilder.yml` specified `exec_args: "$APPDIR/usr/local/bin/chirp"`, but on Python 3.12 the chirp script is installed to `$APPDIR/usr/bin/chirp` (without `/local/`). This caused the error:
```
can't open file '/tmp/.mount_Chirp-.../usr/local/bin/chirp': No such file or directory
```

**Solution:** Updated `exec_args` in `AppImageBuilder.yml`:
```yaml
exec_args: "$APPDIR/usr/bin/chirp"
```

### 8. Incorrect PYTHONPATH (Python 3.8/3.10 instead of 3.12)

**Problem:** The `PYTHONPATH` environment variable in `AppImageBuilder.yml` referenced Python 3.8 and 3.10 site-packages directories, but CHIRP is installed in Python 3.12 site-packages. This caused:
```
ModuleNotFoundError: No module named 'chirp'
```

**Solution:** Updated `PYTHONPATH` in `AppImageBuilder.yml`:
```yaml
PYTHONPATH: $APPDIR/usr/lib/python3/dist-packages:$APPDIR/usr/lib/python3.12/site-packages
```

---

## Files Created

| File | Description |
|------|-------------|
| `build_local.sh` | Alternative build script that downloads CHIRP from `archive.chirpmyradio.com` instead of Backblaze B2 |
| `venv/` | Python virtual environment with appimage-builder installed |
| `BUILD_REPORT.md` | This file |

## Files Modified

| File | Changes |
|------|---------|
| `AppImageBuilder.yml` | Removed `comp: zstd`, fixed chirp.png path to Python 3.12, fixed `exec_args` from `/usr/local/bin/chirp` to `/usr/bin/chirp`, updated `PYTHONPATH` from Python 3.8/3.10 to Python 3.12 |
| `venv/lib/python3.12/site-packages/appimagebuilder/modules/deploy/apt/package.py` | Added try/catch for `InvalidVersion` in `__gt__` method |

---

## How to Rebuild

```bash
# 1. Activate the virtual environment
source venv/bin/activate

# 2. Run the build script
./build_local.sh
```

The build script will:
1. Download the latest CHIRP wheel from `archive.chirpmyradio.com`
2. Run `appimage-builder` with the `AppImageBuilder.yml` recipe
3. Produce a `.AppImage` file in the current directory
