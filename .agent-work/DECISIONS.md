# NEXORA OS — engineering decisions

Last updated: 2026-11-11

## Confirmed constraints

1. **Target distribution:** Ubuntu 26.04 LTS (Resolute Raccoon). Fix Ubuntu build compatibility; do not switch the target to Debian or another distribution to bypass a failure.
2. **Initial architecture:** AMD64 / x86-64 only. No ARM support in Version 1.0.
3. **Two desktop experiences / one installation:** NEXORA Classic and NEXORA Flow share the OS install, user account, home directory, files, applications and underlying system services.
4. **Shared desktop technology:** KDE Plasma is the initial common desktop technology foundation; it is not itself the finished Classic or Flow product.
5. **Live-image trust:** Preserve signed Ubuntu snapshot metadata and package identity. Transport fallbacks must use exact object paths and checksum/size validation.
6. **Installer safety:** Real disk writes are not acceptable test targets. Automated installation tests use disposable VM disks; destructive user-disk operations need explicit safeguards and authorization.
7. **Security claims:** Do not advertise Secure Boot, full-disk encryption, LUKS recovery, update rollback, or hardware support without end-to-end test evidence.
8. **Release claims:** Engineering artifacts and synthetic test images are not production release evidence.
9. **Repository scope:** Work only on `ravaunrichards/NEXORA-OS-1.0`; do not merge to main or publish releases in this execution without the required review/authorization.

## Decisions not yet approved

- Project license: no license has been selected; do not infer permission from public visibility.
- Main-branch protection: documentation says it is currently unprotected. Owner action and read-back verification are required.
- Secure Boot signing key and enrollment model: not selected.
- Default filesystem: ext4 is the conservative recommendation; Btrfs snapshots require a tested rollback/recovery design before being selected.
- Default software collection and optional-pack policy: product definition is recorded in STAGE_QUEUE.md; final package selection follows image size, trust and compatibility tests.

## Active technical investigation

Ubuntu Resolute's packaged live-build currently fails in its Ubuntu-mode Syslinux stage because legacy Ubuntu theme packages are no longer available. A public report records the same package failure and also reports that the alternative GRUB path requests obsolete `grub-legacy`. Ubuntu's current `lb config` manpage documents explicit distribution, parent distribution, archive areas, bootstrap keyring, initramfs and Syslinux-theme options.

Candidate remediation: retain Ubuntu Resolute suite, Ubuntu mirrors/snapshot, Ubuntu archive keyring and Casper initramfs, but use live-build's generic integration path/theme to avoid its stale Ubuntu-specific boot-theme branch. This is only a candidate, not an accepted architectural change, until CI proves (a) the generated chroot is still Ubuntu 26.04, (b) Casper boot files/configuration are correct, (c) the full ISO build passes and (d) actual BIOS/UEFI QEMU boots pass. If it fails, revert or revise the candidate without changing the product's Ubuntu target.

## Change control

Any change to the Ubuntu target, initial architecture, shared-install/two-session requirement, installer data-loss safeguards, authentication/security baseline or release-qualification criteria requires an explicit decision entry and corresponding stage-queue update.


## Verified build-tool compatibility finding (2026-11-11)

Full ISO build #48 confirmed that generic live-build Debian mode's default security-suite construction generated Ubuntu's invalid resolute/updates suite. Ubuntu uses the separate resolute-security pocket, while the regular updates pocket is resolute-updates. The candidate disables only live-build's Debian-mode automatic security source with --security false, adds the signed resolute-security source from the exact dated Ubuntu snapshot during construction, and creates a security.ubuntu.com resolute-security source for the installed system. LB_UPDATES=true is exported in the build process because the installed live-build version accepts that variable but does not provide an --updates command-line option. The regular Ubuntu updates pocket remains enabled. The regression test and probe passed in run #29; a full ISO build remains required before accepting the change.
