# NEXORA OS

NEXORA OS is an independent desktop operating-system project based on **Ubuntu 26.04 LTS (Resolute Raccoon)**. The first hardware target is **AMD64 / x86-64 desktop and laptop PCs**.

The product direction is one installation with two selectable desktop experiences:

- **NEXORA Classic** — a familiar, straightforward desktop.
- **NEXORA Flow** — a modern workspace-oriented desktop.

The intended audiences are home, professional, gaming, creator, and business users.

## Current engineering status

**This repository is at the initial build-foundation stage. It is not a finished operating system, and no production installer or release ISO is available.**

The engineering image is an Ubuntu-based KDE Plasma live environment. An experimental Calamares installer configuration and launcher are being integrated, but real-disk installation is not approved until disposable-VM installation and data-preservation tests pass. NEXORA Classic, NEXORA Flow, custom applications, recovery, hardware qualification, and release signing still require implementation and tests.

Never represent an engineering image as a complete or supported OS release.

## Build foundation

See [Build instructions](build/README.md), [Build architecture](docs/BUILD-ARCHITECTURE.md), and [verified project status](docs/PROJECT-STATUS.md).

A dated Ubuntu archive snapshot is required for every build. On an Ubuntu 26.04 AMD64 build host, install live-build and its tools, then run:

    sudo apt-get update
    sudo apt-get install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin dosfstools mtools isolinux
    sudo env NEXORA_SNAPSHOT=20261109T000000Z bash build/build-iso.sh

The timestamp is an example archive snapshot, not proof that an image has been built. ISO files and SHA-256 checksums are written to dist/. Existing output files are never overwritten.

## Project rules

- Make changes incrementally; preserve working files and configuration.
- Keep Classic and Flow as distinct experiences sharing one OS installation.
- No static mockups or placeholder screens may be reported as implemented features.
- Never mark a milestone complete without inspectable code and relevant test evidence.
- Keep build inputs, package lists, and release artifacts traceable to commits.
- Do not publish a release until installation, boot, security, recovery, and hardware acceptance tests pass.

## Repository workflow

- Read [contribution instructions](CONTRIBUTING.md) before submitting changes.
- Report defects using the issue templates; disclose security vulnerabilities privately using [SECURITY.md](SECURITY.md).
- Use focused branches and pull requests; do not force-push or rewrite shared history.
- The `main` branch is currently unprotected. The repository owner must enable the settings documented in [repository governance](docs/REPOSITORY-GOVERNANCE.md).
- No software license has been selected yet. Until one is added, do not assume that public visibility grants permission to reuse or redistribute project contents.

## Project documentation

- [Current milestone status](docs/PROJECT-STATUS.md)
- [Repository governance and branch protection](docs/REPOSITORY-GOVERNANCE.md)
- [Contribution workflow](CONTRIBUTING.md)
- [Security reporting](SECURITY.md)
- [Build architecture](docs/BUILD-ARCHITECTURE.md)
- [Build and verification instructions](build/README.md)
- [Installer architecture and disk-safety plan](docs/INSTALLER-ARCHITECTURE.md)
- [Calamares integration and test status](installer/README.md)
- [Release acceptance checklist](docs/RELEASE-ACCEPTANCE.md)
