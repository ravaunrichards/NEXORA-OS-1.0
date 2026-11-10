# NEXORA engineering ISO build

This creates a **development-only live ISO** with the NEXORA Calamares installer configuration and application-menu launcher. The installer is experimental and is not approved for real-disk installation until the disposable-disk acceptance tests pass. This is not a production release.

The build creates a BIOS live image with live-build, then adds a separate x86_64 GRUB EFI El Torito image. The final ISO must expose both BIOS and UEFI entries. BIOS live boot parameters direct kernel and systemd diagnostics to both the serial console and VGA so headless QEMU tests can verify that userspace was reached. The serial-argument option was confirmed against the Ubuntu Resolute live-build package. This is standard UEFI boot support only; Secure Boot signing and validation remain separate release gates.

## Supported build host

Use a native Ubuntu 26.04 LTS AMD64 machine. Cross-architecture builds are outside this stage. The build script checks the host release, architecture, available RAM, disk space, and required tools before starting.

Install the build tools:

    sudo apt-get update
    sudo apt-get install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin dosfstools mtools isolinux

## Build

Choose and record a UTC Ubuntu archive snapshot ID. Example:

    sudo env NEXORA_SNAPSHOT=20261110T000000Z bash build/build-iso.sh

The builder rejects a missing or malformed snapshot ID, the wrong host release or architecture, missing dependencies, insufficient resources, and pre-existing output names. It uses a new temporary work directory and does not overwrite prior ISO files.

For network resilience, the build creates a private `wget` wrapper inside its temporary workspace. Signed Release and Packages metadata remains on the selected Ubuntu snapshot. If a version-specific `pool/*.deb` object cannot be fetched promptly from that snapshot, the wrapper retrieves the exact same package path from `archive.ubuntu.com`; it does not change package names or versions. The Ubuntu debootstrap downloader checks the downloaded package's size and checksum against the pinned Packages index before accepting it. Other download failures receive up to four attempts. The system `wget` executable and installed `debootstrap` files are not modified. The fallback decisions are recorded in `nexora-download-fallback.log` alongside the build log. If a snapshot `Packages` index object (`Packages`, `.gz`, `.xz`, or `.bz2`) is unavailable, the private wrapper may try the identical relative index path on `archive.ubuntu.com`. The signed snapshot `InRelease`/Release files are never redirected. Debootstrap validates any downloaded index against the checksum and size recorded in the signed snapshot Release file, so a live-archive index that differs from the selected snapshot is rejected.

To select another output directory:

    sudo env NEXORA_SNAPSHOT=20261110T000000Z NEXORA_OUTPUT_DIR=/path/to/output bash build/build-iso.sh

Build workspaces are retained for diagnosis and can be removed manually after reviewing the logs.


Ubuntu 26.04 splits the former monolithic Linux firmware set into supported packages behind the explicit `linux-firmware` metapackage, including `linux-firmware-nvidia-graphics`. The build also passes `--memtest none` to skip live-build's legacy memtest boot-menu helper, which still expects the removed `memtest86+.bin` filename while Ubuntu's `memtest86+` 8.x package ships renamed binaries. This only omits the optional boot-menu memory tester; it does not remove the OS kernel or change installed-system memory diagnostics. The regression test `build/test-live-build-compatibility.sh` protects this setting. The build therefore uses `--firmware-chroot false` to prevent live-build's legacy automatic firmware-name selection from requesting the deleted `nouveau-firmware` package. This does **not** remove the explicitly listed `linux-firmware` package or its supported dependencies. The regression check `build/test-firmware-selection.sh` protects this configuration.

## Verify

    bash build/validate-config.sh
    bash build/verify-iso.sh dist/NEXORA-26.04-amd64-20261110T000000Z.iso
    cd dist
    sha256sum -c NEXORA-26.04-amd64-20261110T000000Z.iso.sha256

The ISO verification checks the ISO filesystem, BIOS and UEFI El Torito entries, and the hybrid USB MBR EFI partition marker (type 0xEF). The synthetic-image test also checks that the EFI image contains `EFI/BOOT/BOOTX64.EFI`. These are structural checks, not substitutes for booting the finished NEXORA ISO in QEMU with UEFI and BIOS firmware and on physical AMD64 hardware.

After any successful ISO build on a branch in this repository, the **NEXORA BIOS and UEFI firmware boot smoke tests** workflow starts automatically and downloads that build's artifact. Builds originating from other repositories are excluded. A manual workflow-dispatch option remains available; for that path, supply the ISO build run ID and exact artifact name. The workflow uses QEMU to test legacy BIOS and OVMF UEFI from both optical ISO media and hybrid USB media, then checks serial logs for a reached live userspace target. It is an automated VM smoke test, not a substitute for physical-device testing.

## Resource requirements

Use a builder with at least 8 GiB RAM and 25 GiB free workspace storage for this initial Plasma-based image. The script refuses to start below those thresholds.

## Evidence

For every candidate, retain:
- source commit SHA;
- Ubuntu snapshot ID;
- build log and retained build workspace;
- ISO file and SHA-256 checksum;
- ISO structure and El Torito verification output;
- QEMU UEFI and BIOS boot-test records;
- later, installer and physical-hardware test records.

Do not call the image reproducible or release-ready based on configuration alone. A successful clean build and repeat-build comparison are still outstanding.
