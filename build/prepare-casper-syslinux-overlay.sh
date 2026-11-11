#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ "$#" -ge 1 && "$#" -le 4 ]] || fail "Usage: $0 OVERLAY_DIR [LB_BINARY_SYSLINUX] [BOOTLOADERS_DIR] [LIVE_BUILD_COMMON_LIBRARY]"

OVERLAY_DIR="$1"
SOURCE_SCRIPT="${2:-/usr/lib/live/build/lb_binary_syslinux}"
BOOTLOADERS_DIR="${3:-/usr/share/live/build/bootloaders}"
LIVE_BUILD_COMMON="${4:-/usr/lib/live/build.sh}"

[[ -n "$OVERLAY_DIR" ]] || fail "Overlay directory must not be empty."
[[ -s "$SOURCE_SCRIPT" ]] || fail "Ubuntu live-build Syslinux script not found: $SOURCE_SCRIPT"
[[ -d "$BOOTLOADERS_DIR/isolinux" ]] || fail "Ubuntu live-build ISOLINUX templates not found: $BOOTLOADERS_DIR/isolinux"
[[ -s "$LIVE_BUILD_COMMON" ]] || fail "Ubuntu live-build common function library not found: $LIVE_BUILD_COMMON"

mkdir -p "$OVERLAY_DIR/scripts/build"
PATCHED_SCRIPT="$OVERLAY_DIR/scripts/build/lb_binary_syslinux"
cp -- "$SOURCE_SCRIPT" "$PATCHED_SCRIPT"

# Ubuntu's current live-build package still hard-codes binary/live paths in
# lb_binary_syslinux. Its linux-image stage correctly stages Casper kernels in
# binary/casper when LB_INITRAMFS=casper. Patch only a private build overlay so
# Syslinux uses the configured initramfs directory without changing system
# packages or files. The package's normal functions and remaining stages stay
# in use.
python3 - "$PATCHED_SCRIPT" "$LIVE_BUILD_COMMON" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
common_library = Path(sys.argv[2])
source = path.read_text(encoding="utf-8")

# Ubuntu Resolute's librsvg2-bin provides rsvg-convert, while this live-build
# stage still checks for and invokes the removed legacy "rsvg" executable.
# Rewrite only standalone command/path tokens in the private stage copy.
legacy_rsvg = re.compile(r"(?<![A-Za-z0-9_-])rsvg(?![A-Za-z0-9_-])")
legacy_rsvg_count = len(legacy_rsvg.findall(source))
if legacy_rsvg_count >= 2:
    source = legacy_rsvg.sub("rsvg-convert", source)
    # The old rsvg CLI accepted INPUT OUTPUT; rsvg-convert uses INPUT -o OUTPUT.
    source, converted_invocations = re.subn(
        r'(rsvg-convert\s+--format\s+png\s+--height\s+480\s+--width\s+640\s+)(?P<input>"[^"]+"|[^\s"]+)\s+(?P<output>"[^"]+"|[^\s"]+)',
        lambda match: match.group(1) + match.group("input") + " -o " + match.group("output"),
        source,
    )
    if converted_invocations < 2:
        raise SystemExit(
            "Unsupported legacy Syslinux SVG renderer layout: expected both chroot and host output invocations."
        )
else:
    # Newer live-build revisions already use rsvg-convert. Accept that layout
    # unchanged, but fail closed if neither complete interface is present.
    modern_rsvg_count = len(re.findall(r"(?<![A-Za-z0-9_-])rsvg-convert(?![A-Za-z0-9_-])", source))
    if modern_rsvg_count < 2:
        raise SystemExit(
            "Unsupported live-build Syslinux theme layout: expected an SVG renderer dependency check and invocation."
        )

# The Resolute package's stage runner can invoke the copied script with its
# helper-library selector empty, yielding the invalid /usr/lib//build.sh.
# Bind the private override to the package-owned, stable common library path.
lines = source.splitlines(keepends=True)
loader_indexes = [
    index
    for index, line in enumerate(lines[:40])
    if "build.sh" in line
    and "/usr/lib/" in line
    and re.search(r"(?<![A-Za-z0-9_])\.\s+.*?/usr/lib/.*?build\.sh", line)
]
if len(loader_indexes) != 1:
    raise SystemExit(
        "Unsupported live-build lb_binary_syslinux layout: expected one common-library include in the first 40 lines."
    )
loader_index = loader_indexes[0]
newline = "\n" if lines[loader_index].endswith("\n") else ""
loader_token = "__NEXORA_COMMON_LIBRARY_INCLUDE__"
lines[loader_index] = f"{loader_token}{newline}"
source = "".join(lines)

anchor = "# Configuring files\n"
if source.count(anchor) != 1:
    raise SystemExit("Unsupported live-build lb_binary_syslinux layout: expected one configuration anchor.")

if source.count("binary/live/") < 2 or source.count("/live/") < 2:
    raise SystemExit("Unsupported live-build lb_binary_syslinux layout: Casper path references were not found.")

initramfs_selector = """# NEXORA: follow live-build's configured initramfs destination (casper/live/boot).
case "${LB_INITRAMFS}" in
    casper) _NEXORA_INITRAMFS_DIR="casper" ;;
    live-boot) _NEXORA_INITRAMFS_DIR="live" ;;
    *) _NEXORA_INITRAMFS_DIR="boot" ;;
esac

"""

source = source.replace(anchor, initramfs_selector + anchor, 1)
source = source.replace("binary/live/", "binary/${_NEXORA_INITRAMFS_DIR}/")
source = source.replace("/live/", "/${_NEXORA_INITRAMFS_DIR}/")
if source.count(loader_token) != 1:
    raise SystemExit("Could not preserve the common-library include during Casper path rewriting.")
source = source.replace(loader_token, f'. "{common_library}"', 1)

required = (
    '. "' + str(common_library) + '"',
    'binary/${_NEXORA_INITRAMFS_DIR}/vmlinuz-*',
    'binary/${_NEXORA_INITRAMFS_DIR}/initrd.img-*',
    '/${_NEXORA_INITRAMFS_DIR}/vmlinuz',
    '/${_NEXORA_INITRAMFS_DIR}/initrd.img',
)
for fragment in required:
    if fragment not in source:
        raise SystemExit(f"Patched Syslinux script is missing expected fragment: {fragment}")

path.write_text(source, encoding="utf-8")
PY

chmod 0755 "$PATCHED_SCRIPT"

# Setting LIVE_BUILD makes Ubuntu's lb dispatcher prefer this one overridden
# stage script. Keep its expected bootloader-template path available from the
# untouched distro package.
[[ ! -e "$OVERLAY_DIR/bootloaders" ]] || fail "Refusing to replace existing overlay bootloaders path."
ln -s "$BOOTLOADERS_DIR" "$OVERLAY_DIR/bootloaders"

bash -n "$PATCHED_SCRIPT"
printf 'Created private Casper-aware live-build overlay: %s\n' "$OVERLAY_DIR"
printf 'Syslinux uses the packaged common library and follows LB_INITRAMFS; system live-build files remain unchanged.\n'
