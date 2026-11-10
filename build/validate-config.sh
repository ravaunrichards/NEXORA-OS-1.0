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

required_files=(
  "$ROOT_DIR/README.md"
  "$ROOT_DIR/CONTRIBUTING.md"
  "$ROOT_DIR/SECURITY.md"
  "$ROOT_DIR/.gitignore"
  "$ROOT_DIR/.github/CODEOWNERS"
  "$ROOT_DIR/.github/PULL_REQUEST_TEMPLATE.md"
  "$ROOT_DIR/.github/ISSUE_TEMPLATE/bug_report.yml"
  "$ROOT_DIR/.github/ISSUE_TEMPLATE/feature_request.yml"
  "$ROOT_DIR/docs/BUILD-ARCHITECTURE.md"
  "$ROOT_DIR/docs/PROJECT-STATUS.md"
  "$ROOT_DIR/docs/REPOSITORY-GOVERNANCE.md"
  "$ROOT_DIR/docs/RELEASE-ACCEPTANCE.md"
  "$ROOT_DIR/docs/INSTALLER-ARCHITECTURE.md"
  "$ROOT_DIR/build/README.md"
  "$ROOT_DIR/build/build-iso.sh"
  "$ROOT_DIR/build/verify-iso.sh"
  "$ROOT_DIR/build/patch-debootstrap-download-retries.sh"
  "$ROOT_DIR/build/test-download-retry-wrapper.sh"
  "$ROOT_DIR/build/test-firmware-selection.sh"
  "$ROOT_DIR/build/run-qemu-live-boot.sh"
  "$ROOT_DIR/build/test-qemu-live-boot.sh"
  "$ROOT_DIR/build/add-uefi-boot.sh"
  "$ROOT_DIR/build/test-add-uefi-boot.sh"
)
for required_file in "${required_files[@]}"; do
  [[ -s "$required_file" ]] || fail "Required project file missing or empty: $required_file"
done

# Every project shell script must at least parse successfully.
while IFS= read -r -d '' script; do
  bash -n "$script" || fail "Shell syntax validation failed: $script"
done < <(find "$ROOT_DIR/build" -maxdepth 1 -type f -name '*.sh' -print0)

# Validate all workflow and issue-form YAML documents with Ruby's standard YAML parser.
command -v ruby >/dev/null 2>&1 || fail "Ruby is required for repository YAML syntax validation."
ruby - "$ROOT_DIR" <<'RUBY'
require "yaml"
root = ARGV.fetch(0)
paths = Dir.glob(File.join(root, ".github", "**", "*.yml")) +
        Dir.glob(File.join(root, ".github", "**", "*.yaml"))
abort "ERROR: No GitHub YAML files found." if paths.empty?
paths.sort.each do |path|
  YAML.parse_file(path)
  puts "YAML syntax passed: #{path.delete_prefix(root + File::SEPARATOR)}"
end
RUBY

bash "$ROOT_DIR/build/test-download-retry-wrapper.sh"
bash "$ROOT_DIR/build/test-firmware-selection.sh"
bash "$ROOT_DIR/build/test-qemu-live-boot.sh"

printf 'NEXORA repository validation passed. Packages checked: %s; YAML files checked: %s.\n' \
  "$package_count" "$(find "$ROOT_DIR/.github" -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | xargs)"
