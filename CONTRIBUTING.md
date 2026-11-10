# Contributing to NEXORA OS

Thank you for helping improve NEXORA OS. The project is an early engineering effort. Contributions must preserve a bootable, testable foundation and must not describe planned work as completed.

## Before starting

1. Read [the project status](docs/PROJECT-STATUS.md), [build architecture](docs/BUILD-ARCHITECTURE.md), and [release acceptance checklist](docs/RELEASE-ACCEPTANCE.md).
2. Check open issues and pull requests for existing work.
3. For a substantial change, open an issue first so its scope and acceptance criteria are clear.
4. Do not upload credentials, signing keys, personal data, proprietary binaries, or secrets.

## Branch and pull-request workflow

- Keep `main` as the integration branch.
- Create a focused branch from the current `main`, for example `build/iso-retry-fix`, `desktop/classic-shell`, or `docs/install-guide`.
- Do not force-push to `main` or rewrite shared history.
- Submit changes through a pull request with the repository template completed.
- Keep pull requests focused and small enough to review.
- Do not merge a change with a failing required check or unresolved safety-critical issue.
- Preserve existing files and user data. Prefer additive changes and explicit migrations.

## Local validation

For repository and manifest checks:

```bash
bash build/validate-config.sh
```

Check all shell scripts:

```bash
find build -maxdepth 1 -type f -name '*.sh' -print0 |
  while IFS= read -r -d '' script; do
    bash -n "$script"
  done
```

Validate the Ubuntu build configuration and synthetic BIOS/UEFI image construction only on a supported Ubuntu 26.04 AMD64 host with the dependencies listed in [build instructions](build/README.md).

A syntax check or synthetic image test is not proof that the complete NEXORA ISO builds or boots. Record the exact commit, workflow run, artifact, checksum, environment, and result.

## Commit messages

Use a short action-oriented prefix:

- `build:` build system or package changes
- `ci:` continuous-integration changes
- `docs:` documentation
- `fix:` defect correction
- `test:` tests
- `feat:` implemented user-visible functionality
- `security:` security-related changes

Do not use `feat:` for plans, placeholders, static mockups, or unimplemented screens.

## Change requirements

Every pull request should:

- explain what changed and why;
- identify affected stages and files;
- list tests actually run and their results;
- identify compatibility, security, and data risks;
- update project status only when evidence justifies it;
- preserve traceability to the relevant Ubuntu snapshot and source commit for build changes.

## Release discipline

Do not publish an engineering ISO as a supported NEXORA release. A release requires the applicable boot, installation, security, recovery, hardware, and QA checks in [release acceptance](docs/RELEASE-ACCEPTANCE.md).
