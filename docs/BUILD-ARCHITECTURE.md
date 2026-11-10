# NEXORA OS build architecture

## Initial target

- Base: Ubuntu 26.04 LTS, codename resolute.
- Architecture: amd64 (x86-64).
- Image type: hybrid live ISO.
- Live boot: Ubuntu-mode live-build with casper package included.
- Bootloader: GRUB, pending actual UEFI and BIOS boot verification.
- Desktop foundation: KDE Plasma packages as a temporary shared base.

## Build-system qualification

The Ubuntu 26.04 archive currently publishes live-build. However, upstream live-build documentation describes derivative modes, including Ubuntu mode, as experimental/best-effort, with derivative projects responsible for supporting their use. This is an engineering starting point, not a claim that live-build is Canonical's official image pipeline or that the first build will work without iteration.

If the first clean build exposes unsupported Ubuntu-specific behavior, stop and resolve that build-system issue before adding desktops or application layers. Do not hide build failures or replace the target OS with Debian.

## Archive pinning

Every build requires NEXORA_SNAPSHOT in UTC YYYYMMDDTHHMMSSZ form. The builder uses the Ubuntu snapshot service for bootstrap and chroot package acquisition. The resulting live environment is configured to use the normal Ubuntu archive and security endpoints for subsequent updates.

This pins the selected Ubuntu archive state used by the initial package build. It does not by itself guarantee bit-for-bit identical ISO bytes. Toolchain versions, build environment, generated timestamps, firmware inputs, and signing steps must also be controlled before claiming full reproducibility.

## Initial package layer

build/packages/nexora-base.list.chroot defines the initial engineering package manifest. It includes live boot, kernel, Plasma desktop, display manager, network, audio, graphics, storage, firmware, and baseline security components.

Package resolution must be proven by a successful build against the selected snapshot. The manifest is deliberately a starting point and may need corrections based on actual resolver and boot-test output.

## What this stage does not provide

- No disk installer, partitioning UI, dual-boot workflow, or disk encryption setup.
- No completed NEXORA Classic or NEXORA Flow desktop.
- No NEXORA app store, updater, welcome center, or control center.
- No custom Secure Boot signing chain or key management.
- No hardware certification, recovery image, or release signing.

These are separate milestones and must not be implied by a successful live ISO build.

## Upstream references

- Ubuntu 26.04 package archive: https://packages.ubuntu.com/resolute/live-build
- Ubuntu Snapshot Service: https://snapshot.ubuntu.com/
- Ubuntu snapshot documentation: https://ubuntu.com/server/docs/how-to/software/snapshot-service/
- Debian Live manual, derivative mode note: https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-package-installation.en.html
