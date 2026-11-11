#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[[ "$#" -eq 2 ]] || fail "Usage: $0 CONFIG_DIR YYYYMMDDTHHMMSSZ"
CONFIG_DIR="$1"
SNAPSHOT="$2"

[[ -n "$CONFIG_DIR" ]] || fail "Usage: $0 CONFIG_DIR YYYYMMDDTHHMMSSZ"
[[ "$SNAPSHOT" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || fail "Snapshot must use YYYYMMDDTHHMMSSZ format."

ARCHIVE_AREAS="main restricted universe multiverse"
SNAPSHOT_MIRROR="https://snapshot.ubuntu.com/ubuntu/$SNAPSHOT"
SECURITY_MIRROR="https://security.ubuntu.com/ubuntu/"

mkdir -p "$CONFIG_DIR/archives"

# Generic live-build Debian mode generates Debian-style /updates security
# suites. Ubuntu instead uses the separately named resolute-security pocket.
# Keep build-time security metadata on the exact dated snapshot and retain
# Ubuntu archive-keyring signature verification.
cat > "$CONFIG_DIR/archives/nexora-security.list.chroot" <<EOF
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] $SNAPSHOT_MIRROR resolute-security $ARCHIVE_AREAS
EOF

# Runtime APT sources must follow Ubuntu's supported security archive, not the
# dated build snapshot, so installed systems continue receiving security fixes.
cat > "$CONFIG_DIR/archives/nexora-security.list.binary" <<EOF
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] $SECURITY_MIRROR resolute-security $ARCHIVE_AREAS
EOF

printf 'Configured Ubuntu security pocket: resolute-security\n'
printf 'Build-time security metadata: %s\n' "$SNAPSHOT_MIRROR"
printf 'Installed-system security mirror: %s\n' "$SECURITY_MIRROR"
