# NEXORA OS — verified project identity

- Repository: `ravaunrichards/NEXORA-OS-1.0`
- GitHub repository ID: `1452288995`
- Canonical Git remote: `https://github.com/ravaunrichards/NEXORA-OS-1.0.git`
- Repository root: GitHub repository root. A local checkout path is not exposed by the connected GitHub interface; do not invent one.
- Project type: Ubuntu-based desktop operating-system distribution / AMD64 hybrid live ISO.
- Base: Ubuntu 26.04 LTS, codename `resolute`.
- Target architecture: AMD64 / x86-64.
- Default integration branch: `main`.
- Current execution branch: `agent/nexora-master-execution`.
- Current branch base: `d8b2085122e094b514caf803921385d57ec435f7` (verified main HEAD at branch creation).
- Project fingerprint: `github-repo:1452288995|main:d8b2085122e094b514caf803921385d57ec435f7`.

## Identity verification policy

Before every resumed execution session and before any repository write, re-fetch repository metadata and confirm the full name, repository ID, canonical clone URL, and default branch. Confirm the intended branch and its latest commit. If any identity field differs, stop all writes.

All changes for this execution are confined to this repository and the isolated execution branch. Never change the remote, force-push, rewrite history, or merge into `main` without a separately verified review and authorization.

## Access limitations

The connected GitHub interface exposes repository metadata and file/branch operations, not a local checkout. Therefore the local filesystem root, local working-tree status, and local uncommitted changes cannot be inspected here. Treat GitHub branch/commit state as the available source of truth and disclose this limitation rather than claiming a local Git check was performed.
