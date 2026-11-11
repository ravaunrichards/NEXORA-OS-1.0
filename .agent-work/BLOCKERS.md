# NEXORA OS — blockers and dependencies

Last reviewed: 2026-11-10.

| ID | Status | Blocker / dependency | Impact | Safe next action |
|---|---|---|---|---|
| B-01 | OPEN | No local repository checkout or shell/container execution is exposed by the connected GitHub interface. | Cannot run local scripts, inspect local uncommitted changes, or perform physical/VM tests from this session. | Use GitHub file/branch/PR/Actions interfaces; use CI for supported tests; disclose unavailable tests. |
| B-02 | OPEN | Full clean Ubuntu 26.04 AMD64 ISO build has not been verified successful. | No bootable engineering ISO release claim. | Inspect latest Actions run and logs; fix exact failure on isolated branch; rerun full build. |
| B-03 | OPEN | Open PR #5 adds pinned snapshot Packages-index transport fallback; full build and CI evidence required. | Build reliability change not integrated. | Review complete patch and checks; do not merge without passing full ISO and validation. |
| B-04 | OPEN | BIOS/UEFI optical and USB boot tests have not been proven for a successful real NEXORA ISO artifact. | Boot compatibility unverified. | Run automated QEMU/OVMF tests against exact ISO artifact/hash after Stage 03. |
| B-05 | OPEN | Calamares is experimental; disposable-VM installation, alongside preservation and encrypted boot are unverified. | Real-disk installation must remain unsupported/disabled. | Complete installer acceptance in disposable VMs only. |
| B-06 | OWNER ACTION | Main branch is documented as unprotected. | Direct pushes may bypass review. | Repository owner must configure documented branch protection/rulesets. |
| B-07 | OWNER DECISION | No project license has been selected. | Redistribution and contribution licensing remain ambiguous. | Owner selects license; do not add one unilaterally. |

## Resolution log

No blocker has been marked resolved in this execution checkpoint. Update status only after verifiable evidence is available.
