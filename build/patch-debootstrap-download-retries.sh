#!/usr/bin/env bash
set -Eeuo pipefail

OUTPUT_DIR="${1:-}"
[[ -n "$OUTPUT_DIR" ]] || {
  printf 'ERROR: Usage: bash build/patch-debootstrap-download-retries.sh /path/to/private-bin\n' >&2
  exit 1
}
REAL_WGET="${NEXORA_REAL_WGET:-$(command -v wget || true)}"
[[ -n "$REAL_WGET" && -x "$REAL_WGET" ]] || {
  printf 'ERROR: A working wget executable is required.\n' >&2
  exit 1
}

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd -- "$OUTPUT_DIR" && pwd)"
WRAPPER="$OUTPUT_DIR/wget"

{
  printf '#!/usr/bin/env bash\n'
  printf 'set -uo pipefail\n'
  printf 'REAL_WGET=%q\n' "$REAL_WGET"
  cat <<'WRAPPER_BODY'
SNAPSHOT_MIRROR="${NEXORA_SNAPSHOT_MIRROR:-}"
ARCHIVE_MIRROR="${NEXORA_ARCHIVE_MIRROR:-https://archive.ubuntu.com/ubuntu}"
DOWNLOAD_LOG="${NEXORA_DOWNLOAD_LOG:-}"

log_message() {
  local message="$1"
  printf '%s\n' "$message" >&2
  if [[ -n "$DOWNLOAD_LOG" ]]; then
    printf '%s\n' "$message" >> "$DOWNLOAD_LOG"
  fi
}

args=("$@")
package_url=""
package_url_index=-1

# Bootstrap and chroot package indexes stay on the pinned snapshot.
# Only version-specific .deb objects may use the archive transport fallback.
if [[ -n "$SNAPSHOT_MIRROR" ]]; then
  for index in "${!args[@]}"; do
    candidate="${args[$index]}"
    if [[ "$candidate" == "$SNAPSHOT_MIRROR"/pool/*.deb ]]; then
      package_url="$candidate"
      package_url_index="$index"
      break
    fi
  done
fi

if [[ "$package_url_index" -ge 0 ]]; then
  package_path="${package_url#"$SNAPSHOT_MIRROR"/}"
  archive_url="${ARCHIVE_MIRROR%/}/$package_path"

  # Give the pinned endpoint a short chance, then fetch the same exact
  # package filename from the archive. debootstrap validates size/checksum
  # from the pinned Packages index before accepting the downloaded file.
  if "$REAL_WGET" --timeout=8 --tries=1 "$@"; then
    log_message "NEXORA package download: pinned snapshot served $package_path"
    exit 0
  fi

  log_message "NEXORA package download: snapshot object failed; using exact-path archive fallback for $package_path"
  args[$package_url_index]="$archive_url"
  last_status=1

  for attempt in 1 2 3 4; do
    if "$REAL_WGET" --timeout=180 --tries=1 "${args[@]}"; then
      log_message "NEXORA package download: archive fallback retrieved $package_path; debootstrap must validate the pinned checksum and size"
      exit 0
    else
      last_status=$?
    fi

    if [[ "$attempt" -lt 4 ]]; then
      log_message "NEXORA package download: retrying archive fallback (attempt $attempt of 4) for $package_path"
      sleep "$attempt"
    fi
  done

  exit "$last_status"
fi

# Keep bounded retries for metadata and non-package wget requests. These
# requests are not rewritten, so package selection remains pinned.
last_status=1
for attempt in 1 2 3 4; do
  if "$REAL_WGET" "$@"; then
    exit 0
  else
    last_status=$?
  fi

  if [[ "$attempt" -lt 4 ]]; then
    log_message "NEXORA downloader: retrying failed metadata request (attempt $attempt of 4)"
    sleep "$attempt"
  fi
done

exit "$last_status"
WRAPPER_BODY
} > "$WRAPPER"

chmod 0755 "$WRAPPER"
printf 'Created isolated snapshot-aware wget wrapper: %s\n' "$WRAPPER"
printf 'Only snapshot pool/*.deb objects can fall back to the exact same package path on archive.ubuntu.com.\n'
printf 'Package checksum and size validation remains the responsibility of debootstrap; system wget and system debootstrap files were not modified.\n'
