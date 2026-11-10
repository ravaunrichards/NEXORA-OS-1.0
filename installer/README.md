# NEXORA installer integration

**Status: initial Calamares configuration implemented in an isolated branch; package/runtime and disk-install acceptance tests are still required.**

## Selected framework

The first installer integration uses Ubuntu Resolute's Calamares 3.3.14 package from Universe. Ubuntu publishes the package in the Resolute archive; its update series is maintained by Ubuntu's Lubuntu developers. NEXORA ships its own configuration under /etc/calamares rather than editing files owned by the Calamares package.

## What this branch adds

- NEXORA-branded Calamares settings and module configuration.
- A live desktop application-menu entry named **Install NEXORA OS**.
- A squashfs deployment source matching the current Casper live-image layout.
- GRUB + initramfs-tools install sequence for the Ubuntu target.
- A required explicit partitioning choice. No erase/replace/alongside/manual option is preselected.
- A mandatory final installation confirmation before Calamares starts its execution phase.
- Cancellation is disabled only after the final confirmation and execution begins, reducing the chance of leaving a half-written installation.
- The packages module removes live-only Calamares/Casper/squashfs-tools from the installed target.
- Automated LUKS partitioning is disabled until NEXORA verifies encrypted boot end-to-end.

## Package additions

The live image requires Calamares, squashfs tools for extracting the live filesystem, GRUB BIOS/UEFI platform binaries, GRUB common tools, and efibootmgr for the install-time bootloader operation. These are explicit packages in the live-image manifest.

## Integration behavior

The live environment offers **Try NEXORA** by continuing to use the Plasma live desktop. **Install NEXORA OS** is an explicit application-menu action; the installer is not automatically launched. Calamares shows language, keyboard, partition selection, account creation, and final review. The install module sequence does not begin until the user confirms the final summary.

This initial integration installs the currently available shared KDE Plasma base. NEXORA Classic and NEXORA Flow are separate future desktop-session milestones; the installer must not claim to install or select those sessions until both have real session packages and their own tests. Their single-install/two-experience requirement remains unchanged.

## Safety boundaries

- Never set initialPartitioningChoice to erase, replace, or alongside.
- Do not enable automated LUKS before the GRUB/initramfs unlock chain is tested.
- No disk write occurs when the user cancels before the final confirmation.
- Only disposable virtual disks may be used by automated installer tests.
- BIOS and UEFI installation, existing-OS preservation, manual partitioning, encryption, recovery, and first-boot validation are not yet accepted.
- This configuration is not a supported installer release until those tests pass.

## Testing

Run:

    bash installer/test-config.sh
    bash build/validate-config.sh

The GitHub installer configuration workflow checks the Ubuntu package exists and that the packaged Calamares module set includes the modules referenced by NEXORA's sequence. A successful config check does not prove that an install to disk succeeds; the disposable-disk acceptance matrix remains mandatory.

## Upstream references

- Ubuntu Resolute Calamares package: https://packages.ubuntu.com/resolute-updates/amd64/calamares
- Calamares partitioning options: https://calamares.io/docs/partitions/
- Calamares configuration deployment guidance: https://github.com/calamares/calamares/wiki/Deploy-Configuration
- Calamares settings example: https://sources.debian.org/src/calamares/3.3.14-1/settings.conf
