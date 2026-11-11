# NEXORA OS — master execution progress

Last updated: 2026-11-11 (PR #5 reverified; repository validation #234 passed; ISO build #54 still active)

## Overall status

- **Version 1.0 release-acceptance completion: 0%.** The repository's release checklist currently records zero accepted release tests. This is not a claim that no source code exists; it means no release acceptance item has been proven for a complete candidate.
- **Roadmap stages:** S00 baseline/recovery is complete. S01 build foundation is active. S02–S12 have not started.
- **Product release status:** NOT RELEASE-READY. No verified engineering ISO artifact is available from the latest build attempts.

## Current checkpoint

- **Current stage:** S01 — Ubuntu 26.04 AMD64 image foundation.
- **Current stage status:** IN PROGRESS.
- **Current task:** Complete a real Ubuntu 26.04 AMD64 ISO build using generic live-build mode, correct Ubuntu APT pockets, signed snapshot metadata and Casper; then verify the image, checksum, hybrid structure and four BIOS/UEFI optical/USB boots.
- **Execution branch:** `fix/snapshot-package-index-fallback`.
- **Open pull request:** [#5](https://github.com/ravaunrichards/NEXORA-OS-1.0/pull/5).
- **Latest verified PR branch HEAD before this tracking update:** `19a46bea5903d735b032f2c3dd4da5649a59df1a`; commits after implementation commit `4e2d4144cc2d9be89b8d5414d1d12e8dc9211994` are execution-record updates only.
- **Latest implementation commit:** `4e2d4144cc2d9be89b8d5414d1d12e8dc9211994`. **Latest repository validation:** run #234 passed on PR #5 (GitHub tested merge ref `04f8e2671610564d2563c13c4c84f11a959b5ad6` incorporating branch HEAD `19a46bea5903d735b032f2c3dd4da5649a59df1a`); run #231 also passed on the implementation commit. **Live-build configuration probe:** run #29 passed on this commit. **Full ISO build:** run #54 is in progress on this commit; no new ISO result is available yet.
- **Baseline commit for the active PR branch:** `366d0ab2330725a55682906c01303b53815c526d`.
- **Last verified main commit:** `d8b2085122e094b514caf803921385d57ec435f7`.
- **Last completed action:** Reverified repository ID, PR #5 base/head and active branch. Repository validation #234 passed; its log confirms manifest checks, YAML parsing, downloader retry and exact-path fallback tests, firmware-selection test, Ubuntu live-build compatibility test, QEMU early-shutdown regression test, and Calamares configuration safeguards. Live-build probe #29 also passed on implementation commit `4e2d4144cc2d9be89b8d5414d1d12e8dc9211994`. Full ISO build #54 remains reported IN PROGRESS; no artifact is published and its live job log is not yet accessible. The build has not been declared failed or successful.
- **Exact next action:** Recheck full ISO build #54 and retrieve its log/artifacts when available. Do not start a duplicate long-running build while #54 remains active. Once it completes, inspect the exact failure (if any) or verify Ubuntu 26.04 Resolute identity, checksum, hybrid structure, then run all four QEMU BIOS/UEFI optical/USB boots. Keep S01 IN PROGRESS until every gate passes.

## Stage register

| Stage | Title | Status | Verified outcome |
|---|---|---|---|
| S00 | Repository identity, recovery and execution records | COMPLETED | Exact repository, main baseline, active PR branch and commit/tree fingerprint recorded; five agent records committed. |
| S01 | Ubuntu 26.04 AMD64 image foundation | IN PROGRESS | Snapshot package/index fallback remains checksum-pinned. Generic live-build probe #29 and repository validation #234 pass. Build #48 exposed the invalid Debian-style resolute/updates suite; the current candidate adds Ubuntu resolute-security sources and keeps resolute-updates enabled. Full ISO build #54 is still reported in progress; no accepted ISO, checksum or real-image boot results yet. |
| S02 | Shared operating-system base and services | NOT STARTED | Plasma login, core devices and services require actual image testing. |
| S03 | NEXORA Classic desktop | NOT STARTED | No completed Classic shell or acceptance tests. |
| S04 | NEXORA Flow desktop | NOT STARTED | No completed Flow shell or acceptance tests. |
| S05 | Safe Calamares installation and desktop selection | NOT STARTED | Installer configuration exists; disk-writing acceptance remains unproven. |
| S06 | Welcome, settings, application and diagnostic centers | NOT STARTED | Functional implementations and integration tests remain. |
| S07 | Security, privacy, Secure Boot and encryption | NOT STARTED | Production policy, signing and LUKS acceptance remain. |
| S08 | Updates, backup and recovery | NOT STARTED | No proven update recovery or data restoration workflow. |
| S09 | Hardware, networking, accessibility and performance | NOT STARTED | Physical hardware matrix and performance evidence remain. |
| S10 | Gaming, creator, developer and specialist packs | NOT STARTED | Optional real package collections and compatibility verification remain. |
| S11 | System-wide QA, documentation and release qualification | NOT STARTED | Release acceptance checklist has zero accepted tests. |
| S12 | Governance and long-term maintenance | NOT STARTED | Branch protection, licensing and supply-chain controls remain open. |

## Files changed in this execution checkpoint

Added:
- `build/configure-ubuntu-archives.sh` — creates build-time signed snapshot `resolute-security` and installed-system security-mirror sources.
- `.agent-work` execution records were initially established during S00.

Modified:
- `build/build-iso.sh` — invokes Ubuntu archive helper; sets `LB_UPDATES=true`; disables only Debian-mode automatic security source generation.
- `build/test-live-build-compatibility.sh` — validates Ubuntu pocket files, keyring path, helper arguments, generic live-build settings and update environment.
- `build/validate-config.sh` — requires the new archive helper as a non-empty project file and validates scripts/tests.
- `.github/workflows/bootloader-option-probe.yml` — verifies live-build options and generated Ubuntu archive sources.
- `build/README.md` — documents correct Ubuntu Resolute security/update pocket handling.
- `.agent-work/PROJECT_IDENTITY.md`, `MASTER_PROGRESS.md`, `STAGE_QUEUE.md`, `DECISIONS.md`, `BLOCKERS.md` — updated repository checkpoint, S01 queue, archive-pocket decision and active blockers.

Removed:
- None.

No existing user files, ISO outputs, databases or repository history were deleted. Main was not modified and PR #5 was not merged.

## Tests and evidence

| Check | Result | Evidence / limitation |
|---|---|---|
| Repository identity and main branch | PASS | GitHub repository metadata and main branch ref verified. |
| Active branch identity | PASS | PR #5 head and parent inspected. |
| PR #5 repository validation (baseline) | PASS | [Actions run #159](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42879056682), head `366d0ab2330725a55682906c01303b53815c526d`. |
| PR #5 repository validation (implementation commit) | PASS | [Actions run #231](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42952121947), commit `4e2d4144cc2d9be89b8d5414d1d12e8dc9211994`; package manifest, repository files, shell scripts, tests and YAML validation passed. |
| PR #5 repository validation (latest) | PASS | [Actions run #234](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42953126942), PR merge ref `04f8e2671610564d2563c13c4c84f11a959b5ad6` incorporating branch head `19a46bea5903d735b032f2c3dd4da5649a59df1a`; 32 required packages, 10 GitHub YAML files, shell syntax and configured regression tests passed. The QEMU script result is a regression-test fixture, not a real boot of the NEXORA ISO. |
| Calamares package/module probe on main | PASS | [Actions run #21](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42860436299); does not prove a disk installation. |
| Historical full ISO run #45 | FAILED | [Actions run #45](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42879047899); obsolete Oneiric Syslinux/gfxboot packages unavailable. No ISO produced. |
| Full ISO run #48 | FAILED | [Actions run #48](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42948065764); bootstrap succeeded, but chroot APT attempted invalid resolute/updates and received HTTP 404. Current candidate adds Ubuntu resolute-security sources and retains resolute-updates; rerun #54 is active. |
| Full ISO run #54 | IN PROGRESS (last observed) | [Actions run #54](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42952118414), source commit `4e2d4144cc2d9be89b8d5414d1d12e8dc9211994`; build step remains active, upload step is pending, and no artifact is available. No result or ISO is claimed. |
| Live-build configuration probe | PASS | [Run #29](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42952118513), commit `4e2d4144cc2d9be89b8d5414d1d12e8dc9211994`; generic mode, Resolute suite, keyring, Casper, security setting and archive-helper regression passed. |
| Synthetic ISO boot-structure tests | PASS (synthetic only) | Existing CI evidence records BIOS/UEFI El Torito entries and hybrid EFI partition; not a real NEXORA ISO boot. |
| BIOS/UEFI QEMU boot of a NEXORA ISO | NOT RUN / NOT PASSED | Boot workflow was skipped after ISO build failure. |
| Local Git status and local tests | UNAVAILABLE | No local checkout; clone blocked by DNS resolution. |

## Errors discovered and disposition

1. Snapshot Packages index objects intermittently failed from the pinned snapshot endpoint. PR #5 adds same-relative-path transport fallback while preserving signed snapshot metadata and debootstrap checksum/size verification. Its targeted repository validation passes; its full ISO result is not yet successful.
2. The live-build Ubuntu-mode Syslinux path failed on run #45 due obsolete Oneiric theme/gfxboot packages. The current candidate uses generic live-build mode while explicitly pinning Ubuntu Resolute suite, Ubuntu archive keyring, Casper initramfs and archive areas; post-build squashfs checks reject non-Ubuntu 26.04/Resolute. This candidate is not accepted until the probe and a complete image build pass.
3. A later candidate commit had malformed rootfs-verification shell syntax and malformed YAML workflow content; both were corrected and caught by CI before acceptance. Full build #48 then exposed the Ubuntu APT pocket mismatch: generic Debian mode generated resolute/updates, which Ubuntu does not publish. The candidate now sets LB_SECURITY=false and adds a signed resolute-security source from the pinned snapshot, plus a runtime security.ubuntu.com resolute-security source. It keeps resolute-updates enabled using exported LB_UPDATES=true because this installed live-build version has no --updates CLI option. Probe #29 and repository validation #231 passed. Full build #54 is active; no image result is verified.
4. Earlier `nouveau-firmware` and removed memtest filename failures have targeted regression checks; the full build must still demonstrate that downstream stages pass.

## Outstanding defects and dependencies

- S01: Probe and repository validation pass for the Ubuntu pocket fix. Full build #54 is in progress. Then verify a real ISO, checksum, hybrid structure and all BIOS/UEFI optical/USB QEMU tests.
- S02–S10: Product capabilities listed in STAGE_QUEUE.md are unimplemented or unverified.
- S11: No end-to-end release evidence; no production release.
- S12: Main branch protection is not enabled; no project license has been selected.
- Environment: No local checkout is mounted; local commands cannot be executed here.

## Last successfully completed action

Repository identity and existing state were checked, and the agent execution/progress records were created on the existing PR branch without changing `main`.

## Exact next action

On the same active branch, inspect full ISO build #54 and its logs. Fix the next actual failure with a minimal change, repeat validation/probe/build, then run checksum, ISO-structure and four QEMU boot cases. Keep S01 IN PROGRESS until all acceptance gates pass.
