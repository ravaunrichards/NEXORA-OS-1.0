# NEXORA OS installer architecture and safety plan

**Status: design baseline only — no disk installer is implemented or enabled yet.**

This document defines the next installer milestone for the Ubuntu 26.04 LTS AMD64 live system. It is deliberately separate from the ISO build so installer work cannot destabilize the bootable-image foundation.

## Recommended installer foundation

Use **Calamares 3.3.14** as the first NEXORA installer candidate, packaged from Ubuntu Resolute's `universe` repository. The current Resolute updates package is `3.3.14-0ubuntu25.26.04.1`. Calamares is distribution-independent and supports a separately shipped distribution configuration under `/etc/calamares`; do not patch the files shipped by the upstream package.

Why this candidate fits the current NEXORA direction:

- The live-image base is KDE Plasma, and Calamares is designed to be branded and configured by independent distributions.
- It has modules for the install flow, partition selection, filesystem deployment, user creation, bootloader setup, and system configuration.
- Its LUKS support can be integrated with Debian/Ubuntu `initramfs-tools` and GRUB, but that integration must be tested on NEXORA's exact target image before encryption is advertised as supported.

Ubuntu's own desktop installer is the alternative to retain as a reference: it uses the Flutter-based `ubuntu-desktop-bootstrap` frontend and Subiquity backend. Do not mix both installer stacks into the same image. Re-evaluate the choice if Calamares fails the NEXORA VM acceptance tests.

## Product experience

The live environment must provide two clear paths:

1. **Try NEXORA** — start the live desktop without writing to internal disks.
2. **Install NEXORA** — open the branded installer only when the user explicitly selects it.

The installer must preserve the one-installation / two-desktop product direction:

- Install the shared NEXORA base once.
- Include both NEXORA Classic and NEXORA Flow desktop experiences in the installed system.
- Let the user choose the initial default desktop during installation.
- Keep both choices available at the login screen so the user can switch later without reinstalling or duplicating user data.

## Installer screen sequence

1. Welcome, language, and accessibility
2. Keyboard layout
3. Optional network connection and update choice
4. Installation target and partitioning method
5. Partition preview, mount points, and filesystem summary
6. Optional LUKS2 encryption and recovery-key guidance
7. User account, device name, and time zone
8. Default desktop: Classic or Flow
9. Final review of every disk and partition change
10. Explicit confirmation, installation progress, and completion
11. Reboot guidance and first-boot checks

The installer must show a complete summary before any disk-writing job is queued.

## Storage modes

The initial interface should expose:

- **Erase selected disk and install NEXORA** — only after explicit disk selection and a second destructive-action confirmation.
- **Install alongside an existing operating system** — only when the partition layout is positively detected and the existing system's partitions can be preserved.
- **Manual partitioning** — advanced users may choose mount points and formats explicitly.

UEFI installations use GPT and a FAT32 EFI System Partition. Legacy BIOS installations are supported only when the booted image and target layout are compatible. Existing EFI System Partitions must be reused without formatting during an alongside installation unless the user explicitly opts into a clearly explained destructive action.

## Data-loss prevention requirements

These requirements are release blockers, not optional UI polish:

- Never preselect a disk for erasure.
- Never infer the target disk from device order, disk size, or the first discovered drive.
- Display the disk model, capacity, device path, and existing partitions; ask the user to select the exact target.
- Clearly identify every partition that will be created, resized, formatted, mounted, or preserved.
- Do not run partition-table writes, filesystem creation, formatting, or wipe operations before the final confirmation.
- Require a second confirmation for any action that removes or formats existing partitions; make the affected disk and data-loss consequence explicit.
- Cancel/back before the final confirmation must leave all target disks unchanged.
- Abort rather than guess when disk identity, boot mode, partition relationships, or free-space calculations are ambiguous.
- Do not format an existing EFI System Partition in an alongside installation.
- Never use a test or CI machine's host disk as an installation target. Automated installer tests must use disposable virtual disks.
- Preserve installer logs and the pre-install partition inventory for diagnosis.

## Encryption and boot chain

The first encrypted-install target should be **LUKS2 root encryption with GRUB 2 and the Ubuntu initramfs-tools boot path**. A separate EFI System Partition remains unencrypted so UEFI firmware can load the signed boot chain.

Calamares documents a specific LUKS integration sequence for Debian/Ubuntu derivatives: `luksbootkeyfile`, `initramfscfg`, `initramfs`, and GRUB cryptodisk configuration. Implement those modules only after confirming that the exact packages and module names exist in the Ubuntu Resolute build environment. Do not use systemd-boot for this encrypted-root design; Calamares documents that its full-disk-encryption flow requires GRUB 2.

Start with one encrypted root volume. Do not advertise multi-LUKS layouts, encrypted swap/resume, TPM-backed unlock, or unattended unlock until they have independent tests and recovery procedures. The current Resolute Calamares update includes a fix relating to multiple LUKS devices, but this is not a substitute for NEXORA-specific testing.

Secure Boot is a separate acceptance gate. The installer must use the supported signed Ubuntu kernel, shim, and GRUB packages and must not claim Secure Boot support until a Secure Boot VM test and key/enrollment documentation pass.

## Desktop and first-boot integration

- Keep the shared user account, home directory, personal files, and system services common to both desktops.
- Install and register both desktop sessions.
- Set the selected desktop as the initial login default without deleting the other session.
- Confirm that switching Classic/Flow does not reset user preferences, remove applications, or change home-directory ownership.
- Show a clear first-boot checklist for network, updates, hardware/driver status, time zone, and recovery information.

## Required installer test matrix

All tests must use disposable virtual disks and record the source commit, ISO checksum, VM firmware, disk layout, installer log, and result.

| Test | Expected result |
|---|---|
| UEFI + blank GPT disk | Clean installation boots into the chosen desktop |
| BIOS + blank MBR disk | Installation and legacy boot work where supported |
| UEFI + existing Windows installation | Alongside install preserves Windows partitions and existing EFI files |
| UEFI + existing Linux installation | Alongside install preserves the existing system and provides a selectable boot entry |
| Manual partitioning | Only explicitly selected partitions are changed |
| LUKS2 encrypted root | Correct passphrase unlocks; wrong passphrase fails safely; recovery path is documented |
| Cancel before final confirmation | No partition table or filesystem changes |
| Destructive install confirmation | Only the explicitly selected disk is modified |
| Installer failure / interrupted install | Clear error logs; no false success; documented recovery |
| Classic / Flow selection | Both sessions remain installed and selectable after reboot |
| Upgrade and reinstall | User data and the other desktop session are preserved where the selected mode promises preservation |

## Stage acceptance criteria

Stage 4 is complete only when:

- Calamares launches from the NEXORA live desktop with NEXORA branding.
- The install flow works in UEFI and BIOS virtual machines for supported layouts.
- Blank-disk, alongside, and manual partitioning have passed the relevant tests.
- LUKS2 encryption and boot unlock pass end-to-end tests before being exposed as a supported feature.
- Cancel and final-confirmation safeguards prove that no disk is modified early.
- Both desktop experiences are installed and selectable from one installation.
- Installation logs, checksums, and test reports are linked to a commit.

A configuration file, installer screenshot, or successful package installation is not proof that the installer works.

## Current implementation boundary

This is the installer design baseline only. It does not add Calamares to the ISO manifest, enable a disk-writing command, create partitions, modify bootloader settings, or claim that an installer exists. Integration starts only after the ISO foundation is verified and the installer package/module set is validated in the target live environment.

## References

- Ubuntu Resolute Calamares package: https://packages.ubuntu.com/resolute-updates/amd64/calamares
- Calamares deployment configuration: https://calamares.codeberg.page/docs/deploy-configuration/
- Calamares LUKS deployment guide: https://calamares.codeberg.page/docs/deploy-luks/
- Calamares tester's guide: https://calamares.codeberg.page/docs/test-guide/
- Ubuntu Subiquity/autoinstall reference: https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html
- Ubuntu Desktop bootstrap project: https://github.com/canonical/ubuntu-desktop-provision
