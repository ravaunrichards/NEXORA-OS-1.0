# NEXORA OS security policy

NEXORA OS is an early-stage operating-system project. It is not currently a supported production operating system.

## Reporting a vulnerability

Please do not publish security vulnerabilities, exploit details, credentials, or sensitive logs in public issues or pull requests.

Preferred reporting route: use the repository's **Security** tab and its **Report a vulnerability** option when private vulnerability reporting is available.

If that option is unavailable, contact the repository owner privately through the owner's GitHub profile. Include a concise description, affected commit or workflow, impact, reproduction information, and a suggested mitigation where possible. Do not include passwords, private keys, recovery keys, or unrelated personal data.

## Response expectations

This is a project policy, not a guaranteed service-level agreement. Reports will be reviewed as project capacity allows. Please allow time for triage and coordinated remediation before public disclosure.

## Scope

Potentially relevant reports include:

- privilege escalation or unsafe default permissions;
- insecure boot, update, package, or signing behavior;
- data loss or encryption/recovery defects;
- vulnerabilities in NEXORA-maintained scripts, workflows, or components;
- supply-chain integrity and artifact verification failures.

Third-party Ubuntu, KDE, kernel, and package vulnerabilities should identify the upstream component and version where possible.

## Safe testing

Only test systems and data that you own or are explicitly authorized to assess. Use disposable virtual machines and test disks for destructive installation, partitioning, encryption, and recovery tests.
