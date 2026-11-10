# NEXORA OS repository governance

## Repository baseline

Repository: [ravaunrichards/NEXORA-OS-1.0](https://github.com/ravaunrichards/NEXORA-OS-1.0)

The repository is public and uses `main` as its default branch. The project has contributor guidance, a pull-request template, issue forms, a security reporting policy, and a CODEOWNERS file.

## Main-branch protection

**Current verified state (2026-11-10): protection is not enabled.** GitHub reports the `main` branch as unprotected and no repository rulesets are configured.

The connected repository interface can inspect branch protection and rulesets but does not expose an administrative write action to create or change them. Do not report the branch as protected until the repository owner applies and verifies the settings in GitHub.

Recommended settings for the `main` branch:

1. Open repository **Settings → Branches** and add a branch protection rule for `main`.
2. Require a pull request before merging. The project currently has a single primary maintainer, so do not require an approval count that would prevent that maintainer from merging their own reviewed pull request. Increase the approval requirement when additional reviewers are available.
3. Require the successful **validate** status check before merging. Confirm the exact check name in GitHub's status-check selector.
4. Require conversations to be resolved before merging.
5. Block force pushes and branch deletion.
6. Keep administrators subject to the rule where practical.
7. Re-check the branch API/settings after saving and record the result here.

Until protection is enabled, contributors should follow the pull-request workflow, but direct pushes to `main` are not technically blocked.

## Pull requests and review

- Use focused feature or fix branches.
- Include a summary, scope, risk notes, and test evidence.
- Use CODEOWNERS to request maintainer review when the branch protection/review workflow is enabled.
- Do not merge failing validation checks or changes with unresolved data-loss/security risks.
- Do not claim a feature, ISO, boot path, or release is complete without reproducible evidence.

## Issues

Use the bug report and feature request forms. Security vulnerabilities must not be disclosed through public issues; follow [SECURITY.md](../SECURITY.md).

## Licensing

No license has been selected or added to this repository. Do not assume that the public visibility of the repository grants permission to redistribute, modify, or relicense its contents. A license decision requires an explicit project-owner choice.

## Release authority

A successful CI configuration check is not a release. Release publication requires completed evidence in [RELEASE-ACCEPTANCE.md](RELEASE-ACCEPTANCE.md), a verified artifact and checksum, firmware boot tests, and documented known issues.
