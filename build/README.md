# NEXORA engineering ISO build

This creates the first **development-only live ISO**. It does not install NEXORA to a disk and is not a production release.

The build creates a BIOS live image with live-build, then adds a separate x86_64 GRUB EFI El Torito image. The final ISO must expose both BIOS and UEFI entries. This is standard UEFI boot support only; Secure Boot signing and validation remain separate release gates.

## Supported build host

Use a native Ubuntu 26.04 LTS AMD64 machine. Cross-architecture builds are outside this stage. The build script checks the host release, architecture, available RAM, disk space, and required tools before starting.

Install the build tools:

    sudo apt-get update
    sudo apt-get install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin dosfstools mtools isolinux isolinux

## Build

Choose and record a UTC Ubuntu archive snapshot ID. Example:

    sudo env NEXORA_SNAPSHOT=20261110T000000Z bash build/build-iso.sh

The builder rejects a missing or malformed snapshot ID, the wrong host release or architecture, missing dependencies, insufficient resources, and pre-existing output names. It uses a new temporary work directory and does not overwrite prior ISO files.

For network resilience, the build creates a private `wget` retry wrapper inside its temporary workspace. Only the `live-build` process uses this wrapper; failed downloads are retried up to four total attempts with short increasing delays. The system `wget` executable and installed `debootstrap` files are not modified. Package checksums and signature validation remain enabled.

To select another output directory:

    sudo env NEXORA_SNAPSHOT=20261110T000000Z NEXORA_OUTPUT_DIR=/path/to/output bash build/build-iso.sh

Build workspaces are retained for diagnosis and can be removed manually after reviewing the logs.

## Verify

    bash build/validate-config.sh
    bash build/verify-iso.sh dist/NEXORA-26.04-amd64-20261110T000000Z.iso
    cd dist
    sha256sum -c NEXORA-26.04-amd64-20261110T000000Z.iso.sha256

The ISO verification checks the ISO filesystem, BIOS and UEFI El Torito entries, and the hybrid USB MBR EFI partition marker (type 0xEF). The synthetic-image test also checks that the EFI image contains `EFI/BOOT/BOOTX64.EFI`. These are structural checks, not substitutes for booting the finished NEXORA ISO in QEMU with UEFI and BIOS firmware and on physical AMD64 hardware.

After a completed build artifact exists, run the **NEXORA BIOS and UEFI firmware boot smoke tests** workflow in GitHub Actions. Supply the ISO build run ID and exact artifact name. The workflow uses QEMU to test legacy BIOS and OVMF UEFI from both optical ISO media and hybrid USB media, then checks serial logs for a reached live userspace target. It is an automated VM smoke test, not a substitute for physical-device testing.

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
