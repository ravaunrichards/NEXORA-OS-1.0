# NEXORA OS — execution decisions

## Confirmed decisions

1. **Repository lock:** all work belongs only to `ravaunrichards/NEXORA-OS-1.0` (GitHub ID `1452288995`).
2. **Remote:** retain `https://github.com/ravaunrichards/NEXORA-OS-1.0.git`; never change it.
3. **Base OS:** retain Ubuntu 26.04 LTS / Resolute and AMD64 unless a documented technical finding and owner decision justify a change.
4. **Desktop model:** one OS installation, two distinct experiences (NEXORA Classic and NEXORA Flow), sharing applications, files, accounts and system services.
5. **Build evidence:** a configured builder or synthetic fixture is not a successful ISO; a successful ISO is not proof of firmware boot or installation.
6. **Installer safety:** Calamares remains experimental until disposable-VM install and data-preservation acceptance tests pass. Do not perform real-disk installation.
7. **Branch safety:** do not rewrite shared history, force-push, or merge unreviewed changes into `main`. Use isolated branches and PR review.
8. **Feature strategy:** reuse mature upstream Linux components when appropriate; do not rebuild mature components without a concrete requirement.
9. **Completion claims:** only verified functionality and recorded test evidence count as complete.
10. **License:** no license has been selected; public repository visibility is not redistribution permission.

## Current engineering observations

- The repository README and project status describe a development-only engineering image, not a finished OS or production installer.
- Project status reports the ISO build and installer as partial; Classic and Flow remain planned.
- The current build script requires an Ubuntu 26.04 AMD64 host, minimum 8 GiB RAM and 25 GiB free space, a dated snapshot, and refuses to overwrite existing output files.
- Build configuration pins signed snapshot metadata; a narrow exact-path package transport fallback is checksum/size-validated by debootstrap.
- PR #5 proposes a narrow fallback for package-index objects while keeping signed Release metadata pinned. It is not approved for merge without full build and CI evidence.
- The installer configuration is experimental and still needs disposable-disk tests.
- Main branch protection is documented as absent; enabling it is an owner-controlled GitHub settings action.

## Pending decisions

- Select and add an explicit open-source license (project owner decision).
- Enable main-branch protection/rulesets (repository owner action).
- Decide long-term update signing/key custody and Secure Boot signing policy.
- Approve product scope and upstream application choices at the relevant implementation stages.

Record new decisions with date, evidence, impact, and whether owner approval is required. Never infer owner approval from silence.
