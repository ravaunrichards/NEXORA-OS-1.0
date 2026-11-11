# NEXORA OS — verified project identity

Last verified: 2026-11-11 (repository ID, main, PR #5 and Actions checkpoint verified)

## Repository identity

- Repository: `ravaunrichards/NEXORA-OS-1.0`
- Repository ID: `1452288995`
- Canonical remote: `https://github.com/ravaunrichards/NEXORA-OS-1.0.git`
- Repository web URL: `https://github.com/ravaunrichards/NEXORA-OS-1.0`
- Repository root: `/` (Git repository root; no nested project root)
- Default branch: `main`
- Active execution branch: `fix/snapshot-package-index-fallback`
- Active PR: [#5 — pinned snapshot package-index recovery](https://github.com/ravaunrichards/NEXORA-OS-1.0/pull/5)
- Main baseline commit: `d8b2085122e094b514caf803921385d57ec435f7`
- Active branch baseline commit: `366d0ab2330725a55682906c01303b53815c526d`
- Active branch baseline tree fingerprint: `c21dd86adafee0a53dcd548688cb07ebeae762f6`
- Latest verified active PR branch HEAD before this tracking update: `c3d08e1bcfa26fd93ef16eb752377477d5334054`.
- Latest product-code commit: `65c64edfb47ac6f7666708d786d7755af65ac202` (split-package Syslinux staging helper/test and workflow wiring). The subsequent commits through current PR HEAD `c3d08e1bcfa26fd93ef16eb752377477d5334054` update the five `.agent-work` tracking records only. Probe #38 and repository validation #261 pass on PR HEAD; full ISO build #56 is active and #58 is queued.
- The later branch commits include Syslinux asset-source corrections, host dependency changes, probe and regression coverage, documentation, and formatting cleanup. Full ISO build #56 exercises the split-package asset path; build #58 is queued on the latest helper/test revision.
- Visibility: public
- Archived: no
- Verified repository permissions: read, write, maintain and admin

## Project type and technical fingerprint

NEXORA OS is an independent desktop Linux distribution and live-image engineering project. Its declared first-release target is Ubuntu 26.04 LTS (Resolute), AMD64/x86-64, with one shared installation and two selectable desktop experiences: NEXORA Classic and NEXORA Flow.

The current implementation uses Ubuntu archive snapshots, live-build/debootstrap, Casper, a KDE Plasma shared desktop foundation, GRUB/UEFI image assembly, and an experimental Calamares configuration. It is not yet a completed or release-qualified operating system.

## Workspace constraints

The current agent execution environment does not contain a checkout of this repository. A shallow clone was attempted, but network DNS resolution for github.com failed. Consequently, no local root path, local Git branch, local `git status`, or local build/test result is claimed. Repository inspection and commits in this session use the verified GitHub repository and its exact branch refs. GitHub Actions is the available remote validation environment.

## Identity lock

This execution is restricted to `ravaunrichards/NEXORA-OS-1.0`. Do not use another repository's code, configuration, build artifacts, progress records, secrets, databases or services. Re-verify this repository ID, canonical remote, branch and HEAD before every resumed execution. Do not switch remotes, merge into `main`, or publish a release without authorization and verified gates.
