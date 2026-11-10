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
| Repository and project foundation | Partial | Initial documentation and build scripts exist. Branch protection and maintainer workflow remain. |
| Reproducible Ubuntu base build | Partial | Build configuration pins Ubuntu 26.04, AMD64, and an explicit archive snapshot. A successful clean build and repeat-build comparison are still required. |
| NEXORA Classic desktop | Planned | No Classic shell, layouts, settings, or interaction tests. |
| NEXORA Flow desktop | Planned | No Flow shell, workspace, widgets, or interaction tests. |
| System services | Planned | Network, audio, Bluetooth, power, storage, printing, and update integration must be validated. |
| Applications | Planned | No NEXORA application suite or app-store integration. |
| Installer | Planned | No installer, partitioning, dual-boot, or encryption setup. |
| Bootable ISO | Partial | Guarded Ubuntu 26.04 AMD64 live-build pipeline, pinned snapshot, isolated download retries, BIOS-preserving remaster, and UEFI El Torito EFI image are implemented. Synthetic-image CI confirms both BIOS and UEFI entries and extracts `EFI/BOOT/BOOTX64.EFI`. A full NEXORA ISO build, firmware boot tests, and installation tests remain outstanding. |
| Hardware compatibility | Unverified | No hardware test matrix or physical-device results. |
| Security | Planned | Threat model, Secure Boot signing, AppArmor policy, firewall defaults, update trust, and security tests remain. |
| Recovery | Planned | No recovery environment, rollback workflow, or restore tests. |
| QA and release | Planned | No passing end-to-end suite, signed release, or release notes. |

## Latest automated evidence

- Latest completed build-foundation validation: [run #47](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42816621471), PASS.
- Latest isolated UEFI construction test: [run #9](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42816621424), PASS.
- Tested commit: `5db44259ba70503c91facae7046370d9f814dffe`.
- The synthetic-image test confirmed a BIOS El Torito entry and a UEFI El Torito entry, preserved the BIOS image, extracted the EFI system image, and verified `EFI/BOOT/BOOTX64.EFI`.
- This is structural construction evidence only. It does not prove that firmware boots the image or that the live system works.
- Latest full ISO build: [run #22](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42816621757), currently in the live-build stage. No image artifact has been confirmed yet.

Repository currently has one main branch, no pull requests, no issues, and no releases. The main branch is not protected.

## Current release gate

NEXORA is not a release candidate. Do not distribute it as an installable daily-use OS until all release acceptance tests are documented and passed.

## Evidence policy

A configured build is not a successful build. A successful ISO build is not proof of UEFI/BIOS boot, installation, hardware compatibility, or recovery. Record a commit, build log, checksums, test environment, and results for every claim.
