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
| Repository and project foundation | Implemented | Public repository, main branch, project/build documentation, ignore rules, contribution and security policies, CODEOWNERS, PR and issue templates, governance runbook, and passing automated repository validation are in place. See the separate branch-protection and license decisions below. |
| Main branch protection | Blocked | GitHub currently reports `main` as unprotected and no rulesets exist. The connected GitHub interface is read-only for branch protection; repository owner must enable the documented rule in [repository settings](https://github.com/ravaunrichards/NEXORA-OS-1.0/settings/branches). |
| Reproducible Ubuntu base build | Partial | Build configuration pins Ubuntu 26.04, AMD64, and signed package metadata from an explicit archive snapshot; versioned package files may use an exact-path archive transport fallback, subject to debootstrap verification. A successful clean build and repeat-build comparison are still required. |
| NEXORA Classic desktop | Planned | No Classic shell, layouts, settings, or interaction tests. |
| NEXORA Flow desktop | Planned | No Flow shell, workspace, widgets, or interaction tests. |
| System services | Planned | Network, audio, Bluetooth, power, storage, printing, and update integration must be validated. |
| Applications | Planned | No NEXORA application suite or app-store integration. |
| Installer | Planned | Calamares is the recommended candidate for the KDE-based live system. The design and disk-safety requirements are documented in [INSTALLER-ARCHITECTURE.md](INSTALLER-ARCHITECTURE.md); no installer has been packaged, integrated, or tested yet. |
| Bootable ISO | Partial | Guarded Ubuntu 26.04 AMD64 live-build pipeline, snapshot-pinned package metadata, narrowly scoped versioned `.deb` transport fallback, isolated downloader, BIOS serial diagnostics, BIOS-preserving remaster, UEFI El Torito image, and hybrid USB EFI MBR marker are implemented. Synthetic-image CI confirms BIOS and UEFI entries, `EFI/BOOT/BOOTX64.EFI`, and MBR partition type `0xEF`. Full NEXORA image generation and firmware boot tests remain outstanding. |
| Hardware compatibility | Unverified | No hardware test matrix or physical-device results. |
| Security | Planned | Threat model, Secure Boot signing, AppArmor policy, firewall defaults, update trust, and security tests remain. |
| Recovery | Planned | No recovery environment, rollback workflow, or restore tests. |
| QA and release | Planned | No passing end-to-end suite, signed release, or release notes. |

## Latest automated evidence

- Latest completed repository validation before this firmware fix: [run #104](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42843206466), PASS on commit `d1ae3f3b7fc59c0d9a07482420d81f7f26ca2870`. It validated the package manifest, required project files, shell syntax, workflow/issue YAML, retry logic, and exact-path package fallback. The firmware-selection regression test is added in the current fix branch and must pass before merge.
- The governance-pack changes add contributor/security policies, CODEOWNERS, structured issue forms, PR checklist, and main-branch protection instructions.
- The validation workflow is scoped to project source, build, documentation, and GitHub configuration paths, so unrelated repository activity does not trigger unnecessary validation runs.
- Latest synthetic BIOS/UEFI/hybrid construction test: [run #13](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42818732011), PASS. It confirms BIOS and UEFI El Torito entries, `EFI/BOOT/BOOTX64.EFI`, and MBR EFI partition type `0xEF`.
- Latest Ubuntu Resolute live-build option probe: [run #3](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42834075721), PASS. It confirms the supported singular `--bootloader syslinux` option and persists the configured BIOS serial-console arguments via `--bootappend-live`; the plural `--bootloaders` form is rejected.
- The production ISO builder and standalone verifier reject images missing the BIOS/UEFI entries or the hybrid EFI MBR marker.
- The QEMU/OVMF firmware smoke-test workflow starts automatically after any successful ISO build on a branch in this repository and also retains its manual dispatch path; builds from other repositories are excluded. It covers optical and USB paths under BIOS and UEFI. This same-repository branch trigger allows pull-request build artifacts to enter Stage 3 without a manual handoff. No successful ISO artifact is verified yet.
- Full ISO build [run #27](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42818732087), source commit `e2243be239a3b673690545971f16a8855aa1f141`, FAILED inside live-build. Its artifact contains logs only, no ISO. The archived log shows mass bootstrap package-download failures from the pinned snapshot endpoint, ending with three missing packages and a secondary incomplete-chroot error.
- Pre-fallback build [run #28](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42834318631), source commit `923ce9f56f8e44bd80f1e7ae9b9c4e64c313470f`, also FAILED in live-build; eight bootstrap packages could not be downloaded. Its artifact contains logs only, no ISO. This confirms the need for the new package transport fallback.
- Snapshot diagnostics [run #4](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42837937451) PASS: sample exact-version package URLs frequently returned HTTP 503 or timed out on `snapshot.ubuntu.com`, while identical filenames on `archive.ubuntu.com` returned HTTP 200.
- The private `wget` wrapper now falls back only for a version-specific `.deb` under the pinned snapshot's `pool/` path, requesting the identical relative filename from the Ubuntu archive. Bootstrap/chroot metadata, release signatures, and version selection remain snapshot-pinned. The fallback and retry behavior pass repository validation #93 and #96. The installed Ubuntu Resolute debootstrap 1.0.142ubuntu2 implementation uses `wget` from `PATH`; its `download_debs` path passes each package's checksum and expected size from the pinned package index into `get()` before accepting the package. See diagnostic [run #5](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42839872890).
- Latest full ISO build [run #31](https://github.com/ravaunrichards/NEXORA-OS-1.0/actions/runs/42838901866), source commit `13151790dded300a23f259524c5849d3cc4b8af8`, failed during chroot package installation with `Unable to locate package nouveau-firmware`. The log confirms that the snapshot/package transport stage completed and the failure is package selection, not the checksum-pinned downloader. Ubuntu Resolute has deleted `nouveau-firmware`; the supported `linux-firmware` metapackage now depends on split firmware packages including `linux-firmware-nvidia-graphics`. The current fix branch disables live-build's legacy automatic firmware injection while retaining explicit `linux-firmware`; build success remains unverified until a new full ISO run completes.
- No completed NEXORA ISO, SHA-256 verification, BIOS/UEFI optical or USB boot, or installation test has been verified yet.

The repository has no project issues or releases. The `main` branch remains unprotected until the repository owner applies the documented GitHub setting. No license has been selected; public visibility does not grant redistribution rights.

## Current release gate

NEXORA is not a release candidate. Do not distribute it as an installable daily-use OS until all release acceptance tests are documented and passed.

## Evidence policy

A configured build is not a successful build. A successful ISO build is not proof of UEFI/BIOS boot, installation, hardware compatibility, or recovery. Record a commit, build log, checksums, test environment, and results for every claim.
