# NEXORA OS — implementation status

Last updated: 2026-11-10

Status terms:
- **Implemented** — code or configuration exists and the relevant test evidence passes.
- **Partial** — some implementation exists, but the milestone is not complete.
- **Planned** — specified but not implemented.
- **Blocked** — implementation cannot proceed until a named dependency or decision is resolved.
- **Unverified** — evidence is not yet available.

| Milestone | Status | Evidence / remaining work |
|---|---|---|
| Repository and project foundation | Partial | Added contributor/security policies, CODEOWNERS, PR and issue templates, governance runbook, and CI checks for all shell scripts and GitHub YAML. Main branch protection remains disabled and must be enabled by a repository administrator; no license has been selected. |
| Reproducible Ubuntu base build | Partial | Build configuration pins Ubuntu 26.04, AMD64, and an explicit archive snapshot. A successful clean build and repeat-build comparison are still required. |
| NEXORA Classic desktop | Planned | No Classic shell, layouts, settings, or interaction tests. |
| NEXORA Flow desktop | Planned | No Flow shell, workspace, widgets, or interaction tests. |
| System services | Planned | Network, audio, Bluetooth, power, storage, printing, and update integration must be validated. |
| Applications | Planned | No NEXORA application suite or app-store integration. |
| Installer | Planned | No installer, partitioning, dual-boot, or encryption setup. |
| Bootable ISO | Partial | Guarded Ubuntu 26.04 AMD64 live-build pipeline, pinned snapshot, isolated download retries, BIOS-preserving remaster, UEFI El Torito image, and hybrid USB EFI MBR marker are implemented. Synthetic-image CI confirms BIOS and UEFI entries, `EFI/BOOT/BOOTX64.EFI`, and MBR partition type `0xEF`. Full NEXORA image generation and firmware boot tests remain outstanding. |
| Hardware compatibility | Unverified | No hardware test matrix or physical-device results. |
| Security | Planned | Threat model, Secure Boot signing, AppArmor policy, firewall defaults, update trust, and security tests remain. |
| Recovery | Planned | No recovery environment, rollback workflow, or restore tests. |
| QA and release | Planned | No passing end-to-end suite, signed release, or release notes. |

## Latest automated evidence

- Latest completed repository validation for the governance-pack and status-tracker commit: [run #76](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42823237335), PASS. It ran the repository manifest/file checks, syntax-checked every build shell script, and parsed every GitHub workflow and issue-form YAML file.
- The governance-pack changes add contributor/security policies, CODEOWNERS, structured issue forms, PR checklist, and main-branch protection instructions.
- The validation workflow now checks all shell scripts under `build/` and parses every GitHub workflow and issue-form YAML file. A fresh run for the latest documentation updates is expected from the path-scoped workflow.
- Latest synthetic BIOS/UEFI/hybrid construction test: [run #13](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42818732011), PASS. It confirms BIOS and UEFI El Torito entries, `EFI/BOOT/BOOTX64.EFI`, and MBR EFI partition type `0xEF`.
- The production ISO builder and standalone verifier reject images missing the BIOS/UEFI entries or the hybrid EFI MBR marker.
- The manual QEMU/OVMF firmware smoke-test workflow covers optical and USB paths under BIOS and UEFI. It has not been run because no completed NEXORA ISO artifact is available.
- Full ISO build [run #27](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42818732087) is still active inside the live-build stage. No completed ISO artifact is confirmed.
- [Run #25](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42817673502) failed; its result is not being counted as a successful image build.
- No completed NEXORA ISO, real firmware boot, or installation test has been verified yet.

Repository currently has one main branch, no pull requests, no issues, and no releases. The main branch is not protected.

## Current release gate

NEXORA is not a release candidate. Do not distribute it as an installable daily-use OS until all release acceptance tests are documented and passed.

## Evidence policy

A configured build is not a successful build. A successful ISO build is not proof of UEFI/BIOS boot, installation, hardware compatibility, or recovery. Record a commit, build log, checksums, test environment, and results for every claim.
