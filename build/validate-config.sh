#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT_DIR/build/packages/nexora-base.list.chroot"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ -f "$MANIFEST" ]] || fail "Package manifest not found: $MANIFEST"

declare -A seen=()
package_count=0
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="$(printf '%s' "$line" | xargs)"
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[a-z0-9][a-z0-9+.-]*$ ]] || fail "Invalid manifest entry: $line"
  [[ -z "${seen[$line]+present}" ]] || fail "Duplicate package: $line"
  seen["$line"]=1
  ((package_count += 1))
done < "$MANIFEST"

(( package_count > 0 )) || fail "Package manifest is empty"

for required in casper linux-generic plasma-desktop sddm network-manager pipewire wireplumber apparmor btrfs-progs cryptsetup; do
  [[ -n "${seen[$required]+present}" ]] || fail "Required base package missing: $required"
done

for required_file in   "$ROOT_DIR/README.md"   "$ROOT_DIR/docs/BUILD-ARCHITECTURE.md"   "$ROOT_DIR/docs/PROJECT-STATUS.md"   "$ROOT_DIR/build/build-iso.sh"   "$ROOT_DIR/build/verify-iso.sh"   "$ROOT_DIR/build/patch-debootstrap-download-retries.sh"   "$ROOT_DIR/build/test-download-retry-wrapper.sh"   "$ROOT_DIR/build/add-uefi-boot.sh"   "$ROOT_DIR/build/test-add-uefi-boot.sh"; do
  [[ -s "$required_file" ]] || fail "Required project file missing or empty: $required_file"
done

bash "$ROOT_DIR/build/test-download-retry-wrapper.sh"

bash -n "$ROOT_DIR/build/add-uefi-boot.sh"
bash -n "$ROOT_DIR/build/test-add-uefi-boot.sh"

printf 'NEXORA configuration validation passed. Packages checked: %s\n' "$package_count"
