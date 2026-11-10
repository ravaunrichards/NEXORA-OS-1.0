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
| Bootable ISO | Partial | Guarded Ubuntu 26.04 AMD64 live-build pipeline, pinned snapshot, isolated download retries, BIOS-preserving remaster, UEFI El Torito image, and hybrid USB EFI MBR marker are implemented. Synthetic-image CI confirms BIOS and UEFI entries, `EFI/BOOT/BOOTX64.EFI`, and MBR partition type `0xEF`. Full NEXORA image generation and firmware boot tests remain outstanding. |
| Hardware compatibility | Unverified | No hardware test matrix or physical-device results. |
| Security | Planned | Threat model, Secure Boot signing, AppArmor policy, firewall defaults, update trust, and security tests remain. |
| Recovery | Planned | No recovery environment, rollback workflow, or restore tests. |
| QA and release | Planned | No passing end-to-end suite, signed release, or release notes. |

## Latest automated evidence

- Latest completed repository validation: [run #53](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42818164117), PASS.
- Latest BIOS/UEFI/hybrid construction test: [run #12](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42817673330), PASS.
- UEFI test commit: `c0557133f0da16203e0df7dfa4a3537cc167ba1e`; it confirms both BIOS and UEFI El Torito entries, extracts and checks `EFI/BOOT/BOOTX64.EFI`, and verifies MBR EFI partition type `0xEF`.
- Production ISO verification now also requires BIOS and UEFI El Torito entries and the MBR `0xEF` marker. The latest validation for this change passed.
- Structural construction evidence does not prove firmware successfully boots the complete NEXORA live environment.
- Full ISO build run #25 is still active on the earlier commit [run #25](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42817673502). Latest full build run #26, which includes the production `0xEF` check, is queued [run #26](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42818158947).
- No completed NEXORA ISO artifact, real UEFI/BIOS firmware boot, or installation test has been verified yet.

Repository currently has one main branch, no pull requests, no issues, and no releases. The main branch is not protected.

## Current release gate

NEXORA is not a release candidate. Do not distribute it as an installable daily-use OS until all release acceptance tests are documented and passed.

## Evidence policy

A configured build is not a successful build. A successful ISO build is not proof of UEFI/BIOS boot, installation, hardware compatibility, or recovery. Record a commit, build log, checksums, test environment, and results for every claim.
