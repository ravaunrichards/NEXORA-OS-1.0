# NEXORA OS release acceptance checklist

No test is considered passed until its evidence is linked to a commit, image checksum, test environment, and result.

## Boot and installation

- [ ] ISO passes filesystem and El Torito structural verification.
- [ ] ISO boots in a UEFI virtual machine.
- [ ] ISO boots in a legacy BIOS virtual machine where supported.
- [ ] Secure Boot behavior is tested and documented.
- [ ] Live environment reaches a usable desktop without fatal errors.
- [ ] Clean installation completes on a blank AMD64 test disk.
- [ ] Dual-boot installation is tested without damaging the existing OS.
- [ ] Manual and automatic partitioning are tested.
- [ ] Full-disk encryption and recovery-key handling are tested.

## Desktop and system

- [ ] NEXORA Classic starts and its essential navigation works.
- [ ] NEXORA Flow starts and its essential navigation works.
- [ ] Switching desktop experiences preserves user files and settings.
- [ ] Wi-Fi, Ethernet, Bluetooth, audio, graphics acceleration, suspend, resume, and power management are tested.
- [ ] External displays, printers, USB devices, and common storage devices are tested.
- [ ] Accessibility features and keyboard-only navigation are tested.

## Applications, updates, and recovery

- [ ] Applications can be installed, launched, updated, and removed.
- [ ] System updates complete successfully.
- [ ] Failed update rollback or recovery is demonstrated.
- [ ] User data survives update and recovery operations.

## Security and release

- [ ] AppArmor and firewall defaults are tested.
- [ ] Repository and update signature verification is tested.
- [ ] ISO SHA-256 checksum is published and independently verified.
- [ ] Release signing and key custody are reviewed.
- [ ] Hardware compatibility matrix is published.
- [ ] Known issues, supported hardware, installation instructions, and recovery instructions are published.

## Current result

**Passed: 0. Remaining: all tests.**

The build configuration and a successful CI syntax/configuration check are not release acceptance tests. Do not distribute an engineering image as a supported NEXORA OS release.
