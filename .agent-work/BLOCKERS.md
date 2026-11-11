# NEXORA OS — blockers and external dependencies

Last updated: 2026-11-11 (Ubuntu archive-pocket fix; build #54 active)

| ID | Status | Area | Blocker / evidence | Required action | Owner |
|---|---|---|---|---|---|
| B01 | OPEN | S01 build foundation | Build #45 failed on obsolete Oneiric Syslinux/gfxboot packages. Build #48 passed bootstrap but failed because generic Debian-mode live-build generated invalid Ubuntu suite resolute/updates (HTTP 404). Current candidate disables only the invalid automatic security source, adds signed resolute-security sources for build/runtime and retains resolute-updates through LB_UPDATES=true. Probe #29 and repository validation #231 passed; full build #54 is active. | Complete full ISO build #54, inspect the next real error, then verify Ubuntu identity, checksum, hybrid structure and QEMU boot matrix. | Engineering |
| B02 | ACTIVE | Execution environment | No local checkout is mounted; `git clone` could not resolve github.com. Local Git status and local build/test commands are unavailable in this session. | Continue only through verified GitHub branch/tree/commit operations and GitHub Actions; use local execution only when a checkout is actually available. | Environment |
| B03 | OPEN | S12 governance | The `main` branch is currently unprotected, as recorded in repository governance documentation. | Repository owner enables PR/validation protection, prevents force-push/deletion, then verifies branch settings. | Repository owner |
| B04 | OPEN | S12 legal | No project license has been selected or committed. Public repository visibility does not grant redistribution rights. | Owner selects and approves an appropriate license; add the exact license and document third-party notices. | Project owner |
| B05 | OPEN | S01 boot qualification | No complete NEXORA ISO has passed build and boot acceptance. Build #48 produced no ISO; build #54 is still in progress. No checksum or real-image QEMU boot evidence exists. | Complete S01 build, structural verification, checksum and four QEMU boot cases; preserve logs. | Engineering |
| B06 | OPEN | S05 installer | Calamares config/package probes pass, but no blank-disk, alongside Windows/Linux, manual-partition, cancel, failure/recovery or data-preservation install has passed. | After desktop session packages exist, run disposable-disk VM test matrix and preserve logs/inventories. | Engineering |
| B07 | OPEN | S07 security | Secure Boot, LUKS2 encrypted boot/recovery, AppArmor policy and firewall security acceptance are not proven. | Design and run dedicated VM/security acceptance tests before feature claims. | Engineering |
| B08 | OPEN | S08 recovery | Backup, restore, failed-update recovery and user-data preservation have not been demonstrated. | Implement and test end-to-end backup/recovery workflows. | Engineering |
| B09 | OPEN | S09 hardware | No published physical AMD64 hardware compatibility evidence exists. | Execute documented device matrix and publish supported/unsupported combinations with environment details. | Engineering |

## Resolved or progressed issues

- The snapshot package-index download problem discovered on main build #42 has an active correction in PR #5. Validation #159 passed; latest validation #170 also passes after syntax/YAML/regression-test repairs. This is progress, not a completed ISO build and not a merged fix.
- The malformed rootfs-verification shell block, malformed probe-workflow YAML artifact path, and fragile live-build option test were corrected. Later probe fixes addressed the config-dump path collision and source-prefixed output; malformed intermediate workflow revisions were caught by validation and repaired. Full build #48 then identified the invalid Debian-style resolute/updates suite. The current fix adds signed Ubuntu resolute-security sources, retains resolute-updates with LB_UPDATES=true, and tests both build/runtime security source definitions. Probe #29 and repository validation #231 passed on the current implementation commit. Full build #54 is active. B01/B05 remain OPEN until a complete ISO, checksum, hybrid structure and four BIOS/UEFI optical/USB boots pass.
- Earlier obsolete firmware auto-injection and removed memtest filename issues have targeted regression checks; later full-build evidence must still confirm downstream stages.

## Blocker policy

Do not erase blocker history. When a blocker is resolved, record the exact fix commit and successful test evidence, then change its status to RESOLVED. Do not resolve a blocker merely because code exists or a test was queued. Owner-authorized actions (branch protection, license choice and release signing/key custody) remain blocked until the owner actually completes them.
