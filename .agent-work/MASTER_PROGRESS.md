# NEXORA OS — master execution progress

Last updated: 2026-11-11 (Syslinux asset source corrected; validation #257 passed; ISO build #56 active)

## Overall status

- **Version 1.0 release-acceptance completion: 0%.** The repository's release checklist currently records zero accepted release tests. This is not a claim that no source code exists; it means no release acceptance item has been proven for a complete candidate.
- **Roadmap stages:** S00 baseline/recovery is complete. S01 build foundation is active. S02–S12 have not started.
- **Product release status:** NOT RELEASE-READY. No verified engineering ISO artifact is available from the latest build attempts.

## Current checkpoint

- **Current stage:** S01 — Ubuntu 26.04 AMD64 image foundation.
- **Current stage status:** IN PROGRESS.
- **Current task:** Complete a real Ubuntu 26.04 AMD64 ISO build using generic live-build mode, signed Ubuntu archive pockets, Casper and explicitly staged BIOS boot assets; then verify the image, checksum, hybrid structure and four BIOS/UEFI optical/USB boots.
- **Execution branch:** `fix/snapshot-package-index-fallback`.
- **Open pull request:** [#5](https://github.com/ravaunrichards/NEXORA-OS-1.0/pull/5).
- **Latest verified PR branch HEAD before this tracking update:** `65c64edfb47ac6f7666708d786d7755af65ac202`.
- **Latest implementation:** split Ubuntu Syslinux asset staging uses `b8310f6f2f75806701a8264756e37a811292b8b2`; host package/workflow changes are in `81aedf3d04f5fdeca2a4814c60a5cb2f47b6adc4`. **Latest repository validation:** run #257 passed on current branch head `65c64edfb47ac6f7666708d786d7755af65ac202`. **Live-build configuration probe:** run #36 passed on `38e7eadd56dfd1e413f1ab3fbbd968edc9ed7544`; run #38 is in progress on current branch head. **Full ISO build:** run #56 is active on `81aedf3d04f5fdeca2a4814c60a5cb2f47b6adc4`; run #58 is queued on current branch head `65c64edfb47ac6f7666708d786d7755af65ac202`.
- **Baseline commit for the active PR branch:** `366d0ab2330725a55682906c01303b53815c526d`.
- **Last verified main commit:** `d8b2085122e094b514caf803921385d57ec435f7`.
- **Last completed action:** Inspected failed full ISO build #54: Ubuntu APT pockets and keyring worked, but `lb_binary_syslinux` could not find `/root/isolinux/isolinux.bin` and `vesamenu.c32`. Build #55 showed that the initially assumed `/usr/share/live/build/bootloaders/isolinux` copies of those binaries are not present on the actual runner. Corrected the staging helper to retain live-build's menu templates from that directory and overlay the real split-package assets: `/usr/lib/ISOLINUX/isolinux.bin` from `isolinux` and `/usr/lib/syslinux/modules/bios/vesamenu.c32` from `syslinux-common`. The host build/probe workflows now install and verify those packages explicitly. Probe #36 passed using the actual paths, repository validation #257 passed, full build #56 is active and #58 is queued for the latest revision.
- **Exact next action:** Inspect full ISO build #56 and queued #58; do not start a third concurrent long build. If either fails, inspect its retained log/artifact and fix the next observed issue. If a real ISO is produced, inspect its Ubuntu 26.04 identity, SHA-256, BIOS/UEFI El Torito entries and hybrid EFI marker, then complete the four QEMU optical/USB boot cases. Keep S01 IN PROGRESS until all gates pass.

## Stage register

| Stage | Title | Status | Verified outcome |
|---|---|---|---|
| S00 | Repository identity, recovery and execution records | COMPLETED | Exact repository, main baseline, active PR branch and commit/tree fingerprint recorded; five agent records committed. |
| S01 | Ubuntu 26.04 AMD64 image foundation | IN PROGRESS | Snapshot package/index fallback remains checksum-pinned. Ubuntu pocket probe #29 passed. Build #48 exposed invalid resolute/updates; fixed with signed resolute-security and LB_UPDATES=true. Build #54 exposed missing ISOLINUX files; build #55 exposed incorrect assumptions about their packaged locations. The corrected split-package staging probe #36 and repository validation #257 pass. Full build #56 is active; #58 is queued. No complete ISO or real-image boot results yet. |
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
| PR #5 repository validation (latest) | PASS | [Actions run #257](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42959609808), branch head `65c64edfb47ac6f7666708d786d7755af65ac202`; package manifest, repository files, shell syntax, YAML and regression tests including split Syslinux asset staging passed. QEMU script test remains a test fixture, not an actual ISO boot. |
| Calamares package/module probe on main | PASS | [Actions run #21](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42860436299); does not prove a disk installation. |
| Historical full ISO run #45 | FAILED | [Actions run #45](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42879047899); obsolete Oneiric Syslinux/gfxboot packages unavailable. No ISO produced. |
| Full ISO run #48 | FAILED | [Actions run #48](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42948065764); bootstrap succeeded, but chroot APT attempted invalid resolute/updates and received HTTP 404. Current candidate adds Ubuntu resolute-security sources and retains resolute-updates; rerun #54 is active. |
| Full ISO run #54 | FAILED | [Actions run #54](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42952118414); after successful APT refresh and package retrieval, `lb_binary_syslinux` could not find `/root/isolinux/isolinux.bin` and `/root/isolinux/vesamenu.c32`. No ISO produced. |
| Full ISO run #55 | FAILED | [Actions run #55](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42959058415); the first asset staging helper assumed the binaries were both inside the live-build template directory. The runner showed `isolinux.bin` is provided separately by the `isolinux` package. No image build began. |
| Full ISO run #56 | IN PROGRESS | [Actions run #56](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42959543318), commit `81aedf3d04f5fdeca2a4814c60a5cb2f47b6adc4`; host/dependency preflight passed, image build step active. |
| Full ISO run #58 | QUEUED | [Actions run #58](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42959609791), latest branch commit `65c64edfb47ac6f7666708d786d7755af65ac202`; queued by the helper/test cleanup revision. |
| Live-build configuration probe | PASS | [Run #36](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42959539764), commit `38e7eadd56dfd1e413f1ab3fbbd968edc9ed7544`; generic mode, Resolute suite, keyring, Casper, signed security source definitions, and actual split-package ISOLINUX file locations/staging passed. Probe #38 is running on the current revision. |
| Synthetic ISO boot-structure tests | PASS (synthetic only) | Existing CI evidence records BIOS/UEFI El Torito entries and hybrid EFI partition; not a real NEXORA ISO boot. |
| BIOS/UEFI QEMU boot of a NEXORA ISO | NOT RUN / NOT PASSED | Boot workflow was skipped after ISO build failure. |
| Local Git status and local tests | UNAVAILABLE | No local checkout; clone blocked by DNS resolution. |

## Errors discovered and disposition

1. Snapshot Packages index objects intermittently failed from the pinned snapshot endpoint. PR #5 adds same-relative-path transport fallback while preserving signed snapshot metadata and debootstrap checksum/size verification. Its targeted repository validation passes; its full ISO result is not yet successful.
2. The live-build Ubuntu-mode Syslinux path failed on run #45 due obsolete Oneiric theme/gfxboot packages. The current candidate uses generic live-build mode while explicitly pinning Ubuntu Resolute suite, Ubuntu archive keyring, Casper initramfs and archive areas; post-build squashfs checks reject non-Ubuntu 26.04/Resolute. This candidate is not accepted until the probe and a complete image build pass.
3. A later candidate commit had malformed rootfs-verification shell syntax and malformed YAML workflow content; both were corrected and caught by CI. Full build #48 exposed the Ubuntu APT pocket mismatch; signed `resolute-security` sources and `LB_UPDATES=true` were added and probe #29 passed. Full build #54 then reached `lb_binary_syslinux` but failed because the two BIOS files were not staged into `/root/isolinux`. Build #55 showed that the first helper assumed `isolinux.bin` was in live-build's template directory, but that assumption was false on the actual runner. The current helper stages menu templates from `/usr/share/live/build/bootloaders/isolinux`, then overlays `/usr/lib/ISOLINUX/isolinux.bin` and `/usr/lib/syslinux/modules/bios/vesamenu.c32` from explicitly installed Ubuntu packages. Probe #36 and repository validation #257 passed; full build #56 is active, with #58 queued on the latest helper/test revision.
4. Earlier `nouveau-firmware` and removed memtest filename failures have targeted regression checks; the full build must still demonstrate that downstream stages pass.

## Outstanding defects and dependencies

- S01: Ubuntu archive-pocket probe and split-package Syslinux staging probe pass; repository validation #257 passes. Full ISO build #56 is active and #58 is queued. No accepted ISO, checksum, structural verification or real-image boot tests yet.
- S02–S10: Product capabilities listed in STAGE_QUEUE.md are unimplemented or unverified.
- S11: No end-to-end release evidence; no production release.
- S12: Main branch protection is not enabled; no project license has been selected.
- Environment: No local checkout is mounted; local commands cannot be executed here.

## Last successfully completed action

Repository identity and existing state were checked, and the agent execution/progress records were created on the existing PR branch without changing `main`.

## Exact next action

On the same active branch, inspect build #56 and #58 outcomes/logs. Fix the next observed failure, rerun validation/probe/build as needed, and only after an ISO is produced verify checksum, Ubuntu identity, hybrid structure and four QEMU boot cases. Keep S01 IN PROGRESS until all acceptance gates pass.
