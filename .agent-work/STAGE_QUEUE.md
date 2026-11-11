# NEXORA OS — master stage queue

This queue maps the 48-section NEXORA OS master specification to sequential, verifiable work. No requirement is discarded. Mature upstream Linux applications and services may be integrated instead of unnecessarily reimplemented, but must be configured, tested, documented and maintained.

## Execution rules
- Exactly one stage is active at a time.
- Do not start a dependent stage until its prerequisite gates pass.
- Independent audit/documentation tasks may be included only when they directly support the active stage.
- Stage completion requires code/configuration plus recorded acceptance evidence.
- A mockup, package manifest, synthetic image, passing syntax check, or CI configuration alone does not prove end-to-end functionality.
- Keep all changes on focused branches and use reviewed PRs for integration.

## Queue

### STAGE 01 — Repository identity and execution tracking
Status: IN PROGRESS
Objective: Establish verified repository identity and durable execution records.
Tasks:
- Verify repository name, ID, canonical remote, default branch and current commit.
- Inspect whether the five `.agent-work` files already exist before creating.
- Create identity, progress, queue, decisions and blockers records without overwriting existing records.
- Read back every record and verify branch state.
Acceptance: all five files exist on the isolated branch, contain accurate facts, and are readable; no unrelated paths changed.

### STAGE 02 — Baseline audit and open-change reconciliation
Status: READY
Objective: Build a current evidence-based inventory before changing the ISO pipeline.
Tasks:
- Inventory root, workflows, package manifests, build scripts, installer tree, tests and docs.
- Inspect current `main` HEAD and all relevant branches/PRs.
- Review PR #5's complete diff, checks, head/base commits and latest run logs.
- Refresh the latest full ISO build failure and distinguish current failures from historical ones.
- Check for duplicate, stale or contradictory project-status statements.
Acceptance: a path/feature inventory, dependency map, current CI matrix and ranked blocker list are recorded; no PR is merged blindly.

### STAGE 03 — ISO build pipeline reliability
Status: NOT STARTED
Objective: Produce a clean, traceable Ubuntu 26.04 AMD64 engineering ISO.
Tasks:
- Resolve the actual current live-build/debootstrap/package-selection failure.
- Preserve signed snapshot metadata and checksum/size validation.
- Preserve safe download retry/fallback boundaries.
- Correct only supported live-build options and package names.
- Run shell/config/regression checks and full build.
- Verify output naming, no-overwrite behavior, build inputs and SHA-256.
Acceptance: full clean build succeeds; exactly one ISO is generated; verifier and checksum check pass; build log and commit/snapshot evidence retained.

### STAGE 04 — BIOS/UEFI and hybrid-media boot acceptance
Status: NOT STARTED
Objective: Prove the generated image boots in supported firmware modes.
Tasks:
- Verify BIOS and UEFI El Torito entries and EFI bootloader payload.
- Verify hybrid USB EFI MBR marker and media layout.
- Run QEMU/OVMF BIOS and UEFI optical boot tests.
- Run BIOS and UEFI USB-media tests.
- Capture serial logs and verify live userspace reached.
- Record known VM-vs-physical hardware limitations.
Acceptance: all required VM boot paths pass for the exact ISO hash; no test is inferred from a synthetic fixture.

### STAGE 05 — Installer safety and disposable-VM acceptance
Status: NOT STARTED
Objective: Verify experimental Calamares installation safely before real-disk claims.
Tasks:
- Reconcile installer docs/config/launcher/package modules.
- Confirm no disk write occurs before explicit disk/partition choice and final confirmation.
- Test clean install on disposable virtual disk.
- Test alongside-install preservation with disposable existing OS.
- Test EFI, GRUB, initramfs, reboot, user creation and first login.
- Test LUKS/encrypted boot only if the complete chain is configured.
- Test cancellation, failure cleanup and recovery.
Acceptance: repeatable disposable-VM install and data-preservation tests pass; unsafe or unsupported paths remain disabled and documented.

### STAGE 06 — Shared OS foundation and system integration
Status: NOT STARTED
Objective: Establish the maintainable common platform beneath both desktop experiences.
Tasks:
- Define shared service boundaries and configuration ownership.
- Integrate account/session, network, audio, Bluetooth, power, display, storage, printer and update services.
- Define app packaging/source policy and system API boundaries.
- Ensure service failures do not prevent recovery/login.
Acceptance: service integration tests pass on installed system and shared state is not duplicated.

### STAGE 07 — NEXORA Classic desktop
Status: NOT STARTED
Objective: Deliver a familiar, complete desktop experience.
Requirements: start/application menu, taskbar, tray, search, notifications, window controls, shortcuts, context menus, widgets, virtual desktops, drag/drop, pinning and customization.
Acceptance: actual interactive shell with keyboard/mouse and multi-monitor checks; no static mockups or inaccessible controls.

### STAGE 08 — NEXORA Flow desktop
Status: NOT STARTED
Objective: Deliver a genuinely distinct workspace-oriented desktop.
Requirements: dock, workspace navigation, overview, launcher, tiling/split view, widgets, multitasking, full-screen workspace, transitions and user customization.
Acceptance: distinct shell behavior and tested workspace flows; not merely a Classic theme.

### STAGE 09 — Unified services, Control Center and settings
Status: NOT STARTED
Objective: Make both desktops operate the same OS services and user preferences.
Requirements: shared accounts/files/apps/network/printers/notifications/clipboard/security/updates/backups; categorized settings; theme preview/apply/save/reset; desktop switching without losing work.
Acceptance: cross-desktop state consistency and functional-control tests pass.

### STAGE 10 — File manager and Software Center
Status: NOT STARTED
Objective: Deliver safe everyday file and application management.
Requirements: tabs, split panes, previews, search, tags, archives, permissions, network/removable storage, trash, cloud connectors, DEB/Flatpak/AppImage and optional Snap policy, provenance, signatures, permissions, updates and uninstall.
Acceptance: real file/package operations, source attribution and failure/rollback tests pass.

### STAGE 11 — Security, privacy, updates, backup and recovery
Status: NOT STARTED
Objective: Protect data and recover from faults.
Requirements: firewall, encryption, Secure Boot plan, permissions, AppArmor, privacy controls, USB policy, signed updates, snapshots, encrypted backup, restore, rollback, safe mode, boot repair and diagnostics.
Acceptance: threat review, update verification, backup restoration and recovery drills pass; unimplemented protections are not advertised.

### STAGE 12 — Core utilities, notifications and system tools
Status: NOT STARTED
Objective: Complete essential desktop utilities.
Requirements: terminal, calculator, editor, screenshot/recording, archive, disk/system monitor, logs, process manager, clipboard, fonts, webcam/audio, search, notifications, history, DND and per-app controls.
Acceptance: installed utilities launch and perform real operations; notifications respect user settings.

### STAGE 13 — Productivity, browser, mail and communication
Status: NOT STARTED
Objective: Provide a coherent everyday productivity and communications ecosystem.
Requirements: Writer, Sheets, Slides, Notes, Calendar, Tasks, Mail, PDF, Contacts, Clock, browser, downloads, messaging, meetings, remote access and secure file sharing.
Acceptance: supported formats, integrations, permissions and accessibility are tested; upstream apps are credited and maintained.

### STAGE 14 — Gaming, Creator Studio and Developer Hub
Status: NOT STARTED
Objective: Support creative and technical workloads without unsupported compatibility promises.
Requirements: game library/launchers, Steam/Proton where tested, controller/performance/recording/streaming; media editing/recording/conversion/3D integration; editor, terminal, Git, SDKs, compilers, containers, VMs, databases, API tools and debugging.
Acceptance: tested hardware/software matrix, performance measurements and resource controls.

### STAGE 15 — Enterprise and connected-device capabilities
Status: NOT STARTED
Objective: Add optional, modular professional management and secure device pairing.
Requirements: device inventory, deployment, policy, enterprise auth/directory, audit, fleet updates, file/clipboard/notification/media sync and authorized remote control.
Acceptance: opt-in, least-privilege, documented integration tests; home edition remains uncluttered.

### STAGE 16 — Hardware compatibility, accessibility and localization
Status: NOT STARTED
Objective: Qualify real devices and ensure inclusive operation.
Requirements: AMD/Intel/NVIDIA graphics, CPU, Wi-Fi, Bluetooth, audio, webcam, touch, printer/scanner, storage, multi-display, suspend/resume; screen reader, magnification, contrast, keyboard, voice, captions, reduced motion and localization.
Acceptance: published per-device/per-feature test matrix with results and known limitations.

### STAGE 17 — Release hardening, documentation and acceptance
Status: NOT STARTED
Objective: Make a release decision from complete evidence.
Requirements: installer/ISO/security/recovery/hardware/accessibility/performance tests, signing, update/recovery instructions, user/developer docs, known issues, release notes, support and governance.
Acceptance: every mandatory release gate passes on identified artifacts; all remaining limitations are disclosed; no release claim based on plans or mockups.

## Cross-cutting requirements
- Personalization, NEXORA Start Center, Welcome Center, visual identity, shortcuts, sounds/animations, performance dashboards, business editions and future innovations are assigned to Stages 07–16 according to their dependencies.
- All UI must be responsive, accessible, non-overlapping and functional.
- No fabricated activity, ratings, telemetry, compatibility or benchmark claims.
- No secrets in source control; destructive operations require explicit confirmation.
- Preserve existing user data, configuration and repository history.
