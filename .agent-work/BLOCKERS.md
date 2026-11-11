# NEXORA OS — blockers and external dependencies

Last updated: 2026-11-11 (after probe run #8 diagnosis)

| ID | Status | Area | Blocker / evidence | Required action | Owner |
|---|---|---|---|---|---|
| B01 | OPEN | S01 build foundation | Historical full ISO build #45 failed in `lb_binary_syslinux` because obsolete Oneiric theme/gfxboot packages are unavailable. Current candidate uses generic live-build mode with explicit Ubuntu Resolute suite, Ubuntu keyring, Casper and a post-build Ubuntu 26.04 identity guard; full build has not yet proven it. | Run the current live-build probe and full ISO build; fix the next observed failure without changing the Ubuntu target. | Engineering |
| B02 | ACTIVE | Execution environment | No local checkout is mounted; `git clone` could not resolve github.com. Local Git status and local build/test commands are unavailable in this session. | Continue only through verified GitHub branch/tree/commit operations and GitHub Actions; use local execution only when a checkout is actually available. | Environment |
| B03 | OPEN | S12 governance | The `main` branch is currently unprotected, as recorded in repository governance documentation. | Repository owner enables PR/validation protection, prevents force-push/deletion, then verifies branch settings. | Repository owner |
| B04 | OPEN | S12 legal | No project license has been selected or committed. Public repository visibility does not grant redistribution rights. | Owner selects and approves an appropriate license; add the exact license and document third-party notices. | Project owner |
| B05 | OPEN | S01 boot qualification | A complete NEXORA ISO has not been generated; subsequent BIOS/UEFI optical/USB QEMU smoke workflow was skipped after failed image builds. | Complete S01 build, structural verification, checksum and four QEMU boot cases; preserve logs. | Engineering |
| B06 | OPEN | S05 installer | Calamares config/package probes pass, but no blank-disk, alongside Windows/Linux, manual-partition, cancel, failure/recovery or data-preservation install has passed. | After desktop session packages exist, run disposable-disk VM test matrix and preserve logs/inventories. | Engineering |
| B07 | OPEN | S07 security | Secure Boot, LUKS2 encrypted boot/recovery, AppArmor policy and firewall security acceptance are not proven. | Design and run dedicated VM/security acceptance tests before feature claims. | Engineering |
| B08 | OPEN | S08 recovery | Backup, restore, failed-update recovery and user-data preservation have not been demonstrated. | Implement and test end-to-end backup/recovery workflows. | Engineering |
| B09 | OPEN | S09 hardware | No published physical AMD64 hardware compatibility evidence exists. | Execute documented device matrix and publish supported/unsupported combinations with environment details. | Engineering |

## Resolved or progressed issues

- The snapshot package-index download problem discovered on main build #42 has an active correction in PR #5. Validation #159 passed; latest validation #170 also passes after syntax/YAML/regression-test repairs. This is progress, not a completed ISO build and not a merged fix.
- The malformed rootfs-verification shell block, malformed probe-workflow YAML artifact path, and fragile live-build option test were corrected on the PR branch. Repository validation #170 passed. Live-build probe #8 then exposed a new workflow-only defect: its dump target collided with the `config/` directory created by `lb config`. The dump path is now `config-dump.txt` (commit `a9aaf1a74189293e80ff7cc43fc07750319a2d3f`). Probe #10 and full ISO build #48 are being rerun against the corrected configuration. Do not resolve B01/B05 until real ISO and boot acceptance pass.
- Earlier obsolete firmware auto-injection and removed memtest filename issues have targeted regression checks; later full-build evidence must still confirm downstream stages.

## Blocker policy

Do not erase blocker history. When a blocker is resolved, record the exact fix commit and successful test evidence, then change its status to RESOLVED. Do not resolve a blocker merely because code exists or a test was queued. Owner-authorized actions (branch protection, license choice and release signing/key custody) remain blocked until the owner actually completes them.
