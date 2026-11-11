# NEXORA OS — blockers and external dependencies

Last updated: 2026-11-10

| ID | Status | Area | Blocker / evidence | Required action | Owner |
|---|---|---|---|---|---|
| B01 | OPEN | S01 build foundation | Full ISO build #45 on PR #5 fails in `lb_binary_syslinux`: `syslinux-themes-ubuntu-oneiric` cannot be located and `gfxboot-theme-ubuntu` has no installation candidate. | Prove a safe live-build configuration that retains Ubuntu Resolute and Casper, then build the complete image and test it. | Engineering |
| B02 | ACTIVE | Execution environment | No local checkout is mounted; `git clone` could not resolve github.com. Local Git status and local build/test commands are unavailable in this session. | Continue only through verified GitHub branch/tree/commit operations and GitHub Actions; use local execution only when a checkout is actually available. | Environment |
| B03 | OPEN | S12 governance | The `main` branch is currently unprotected, as recorded in repository governance documentation. | Repository owner enables PR/validation protection, prevents force-push/deletion, then verifies branch settings. | Repository owner |
| B04 | OPEN | S12 legal | No project license has been selected or committed. Public repository visibility does not grant redistribution rights. | Owner selects and approves an appropriate license; add the exact license and document third-party notices. | Project owner |
| B05 | OPEN | S01 boot qualification | A complete NEXORA ISO has not been generated; subsequent BIOS/UEFI optical/USB QEMU smoke workflow was skipped after failed image builds. | Complete S01 build, structural verification, checksum and four QEMU boot cases; preserve logs. | Engineering |
| B06 | OPEN | S05 installer | Calamares config/package probes pass, but no blank-disk, alongside Windows/Linux, manual-partition, cancel, failure/recovery or data-preservation install has passed. | After desktop session packages exist, run disposable-disk VM test matrix and preserve logs/inventories. | Engineering |
| B07 | OPEN | S07 security | Secure Boot, LUKS2 encrypted boot/recovery, AppArmor policy and firewall security acceptance are not proven. | Design and run dedicated VM/security acceptance tests before feature claims. | Engineering |
| B08 | OPEN | S08 recovery | Backup, restore, failed-update recovery and user-data preservation have not been demonstrated. | Implement and test end-to-end backup/recovery workflows. | Engineering |
| B09 | OPEN | S09 hardware | No published physical AMD64 hardware compatibility evidence exists. | Execute documented device matrix and publish supported/unsupported combinations with environment details. | Engineering |

## Resolved or progressed issues

- The snapshot package-index download problem discovered on main build #42 has an active correction in PR #5. PR validation #159 passes; PR build #45 advances into the live-build binary stage before exposing B01. This is progress, not a completed ISO build and not a merged fix.
- Earlier obsolete firmware auto-injection and removed memtest filename issues have targeted regression checks; later full-build evidence must still confirm downstream stages.

## Blocker policy

Do not erase blocker history. When a blocker is resolved, record the exact fix commit and successful test evidence, then change its status to RESOLVED. Do not resolve a blocker merely because code exists or a test was queued. Owner-authorized actions (branch protection, license choice and release signing/key custody) remain blocked until the owner actually completes them.
