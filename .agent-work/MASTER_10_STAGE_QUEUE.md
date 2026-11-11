# NEXORA OS 1.0 — authoritative 10-stage execution queue

This is the user-requested master roadmap derived from the approved NEXORA OS 1.0 recommendations. The detailed engineering substage register remains in `STAGE_QUEUE.md`; this 10-stage sequence is the controlling product order.

## Execution contract

- Execute strictly in order: one active stage, then acceptance verification, then advance.
- A stage is complete only when its exit criteria pass on real code/artifacts and the evidence is linked to a commit and test run.
- Build/configuration probes, mockups, package manifests and synthetic fixtures do not substitute for end-to-end acceptance.
- Preserve Ubuntu 26.04 LTS (Resolute), AMD64/x86-64, one shared OS installation, one account/home, and two selectable sessions: NEXORA Classic and NEXORA Flow.
- Keep all implementation inside this repository. Use isolated branches and reviewed pull requests. Never force-push, overwrite outputs, or test destructive installation against user disks.
- Run bounded task batches; checkpoint after meaningful changes. A brief verification/recovery checkpoint between tasks is sufficient; do not create unnecessary delays.
- On resumption, re-verify repository ID, branch, HEAD, open PR, current workflow runs and last successful checkpoint before writing.
- Never claim autonomous background continuation: resume from this ledger when the agent is invoked again. Do not create parallel builds when one is active or queued.

## Master roadmap

### STAGE 1 — Bootable build foundation and image verification
**Status: IN PROGRESS**

Scope:
- Stabilize Ubuntu 26.04 AMD64 live-build/debootstrap.
- Keep dated signed snapshot metadata and checksum-verified exact-path package transport fallbacks.
- Resolve Ubuntu-specific live-build, Syslinux, BIOS/UEFI asset and package selection issues.
- Preserve Casper and prove the generated root filesystem is Ubuntu 26.04 Resolute.
- Produce one engineering ISO without overwriting prior outputs.
- Verify ISO filesystem, BIOS/UEFI El Torito entries, EFI loader, hybrid USB marker and SHA-256.
- Boot the actual ISO in BIOS and UEFI QEMU from optical and USB media; retain logs.

Exit criteria:
A clean full ISO build succeeds; target identity, ISO structure and checksum verify; all four BIOS/UEFI optical/USB smoke tests reach live userspace for the exact artifact.

Current evidence (2026-11-11, refreshed 09:55 UTC):
- Repository validation #317 and #318 passed on the latest PR branch head `e7bb3666fc4613a0dc1b1167a4dde45b5dfe2946`; validation #318 explicitly reports the Casper/Syslinux compatibility overlay regression passed and the original source package file preserved.
- Ubuntu live-build probe #59 passed on the same latest head. It installs the actual Ubuntu Resolute live-build and `librsvg2-bin` packages, executes a real SVG-to-PNG conversion, checks the overlay's exact chroot and host `rsvg-convert ... -o OUTPUT` commands, stages BIOS boot assets, creates the private overlay and confirms that `lb` dispatches the private override.
- Probe logs confirmed the installed Ubuntu live-build script still checks `/usr/bin/rsvg` and invokes `rsvg` in both chroot and host branches, while Resolute's `librsvg2-bin` supplies `/usr/bin/rsvg-convert`. The private overlay now rewrites the dependency check and both invocations to `rsvg-convert`, converts the old positional output form to `-o OUTPUT`, and leaves the packaged script untouched. The regression fixture verifies both converted command forms.
- Full build #61 and #62 failed earlier at the Casper kernel path mismatch. Full build #63 then reached Syslinux but failed with missing legacy `rsvg` (exit 127); it produced no ISO. Build #64 stopped during preflight validation because an intermediate overlay test rejected the package renderer layout; the test was corrected. The redundant intermediate builds #66–#68 were cancelled by GitHub concurrency as later commits superseded them.
- Full build #65 remains in progress on older commit `3aea17d3d645c7061dbcc3acf2a402aa8412ab55`. Its live job logs are not currently downloadable while running; it predates the latest explicit output-argument correction and is not the acceptance build.
- The original PR-branch run #65 remains reported in progress with stale job metadata since 08:44 UTC, and #69 remains pending behind it. Both are being left untouched.
- To avoid this stale per-branch concurrency queue without cancelling/overwriting existing work, recovery branch `recovery/stage1-iso-acceptance` was created from latest verified Stage 1 code commit `e7bb3666fc4613a0dc1b1167a4dde45b5dfe2946`. Its only trigger change is a comment in the ISO workflow; source build scripts and packages are unchanged.
- Isolated full ISO build #70 (run ID `42999044714`) is on recovery branch commit `6c65da37022b23c8891d2392b0a2511ec34297bd`; implementation base remains `e7bb3666fc4613a0dc1b1167a4dde45b5dfe2946`. Latest refresh on 2026-11-11: run status is `in_progress`; job `130450283455` is still on step 4, **Build NEXORA engineering ISO**. Steps 1–3 (runner setup, checkout, Ubuntu 26.04 AMD64 dependency/preflight validation) passed; step 5 (artifact upload) is pending. No artifact exists yet. Fetching the active job log returns Azure `BlobNotFound`; no build failure is established. Do not cancel or duplicate this active build.
- Repository validation #319 passed on the isolated build commit. It explicitly passed the downloader fallback, firmware selection, Ubuntu Resolute live-build/Casper compatibility, BIOS staging, Casper/Syslinux overlay preservation, QEMU early-shutdown and installer safeguard tests.
- Ubuntu live-build probe #59 also passed on the same implementation base commit `e7bb3666fc4613a0dc1b1167a4dde45b5dfe2946`, including exact SVG `rsvg-convert` conversion assertions. A subsequent probe-only commit strengthened the exact output-argument checks without changing ISO builder code. Do not start another competing build while #65/#69 occupy the branch's concurrency group.
- PR #5 remains open and unmerged. Main remains unchanged at `d8b2085122e094b514caf803921385d57ec435f7`.
- After one clean ISO build, verify its Ubuntu 26.04 Resolute root filesystem, ISO structure, BIOS/UEFI El Torito entries, EFI loader, hybrid USB marker and SHA-256. Then the firmware workflow must boot the exact same artifact through BIOS/UEFI optical/USB (all four tests) and reach live userspace.
- On the latest 2026-11-11 refresh, run #70 has no artifacts, checksum or build-info output yet. The firmware workflow has not been triggered for #70 because its `workflow_run` trigger runs only after a successful ISO build. Therefore no ISO structure or live-boot test has been verified; Stage 1 remains IN PROGRESS and Stages 2–10 remain QUEUED.

### STAGE 2 — Shared core operating system and system integration
**Status: QUEUED**

Implement and test the shared installed OS beneath both desktops: SDDM/login, accounts and home, kernel, systemd services, NetworkManager, Wi-Fi/Ethernet, PipeWire audio, Bluetooth, display, USB, storage, printers/scanners, time/locale, power and suspend/resume. Keep services, data and application state shared; measure startup and resource use.

Exit criteria: repeatable installed-system boots/logins and core service tests pass in supported VMs, with shared account and data behavior demonstrated.

### STAGE 3 — NEXORA Classic desktop
**Status: QUEUED**

Implement a genuine traditional desktop: application/start menu and search, panels/taskbar/tray, notifications, desktop icons/wallpaper, windows, snapping, shortcuts, pinning, virtual desktops, quick settings, theme/icon/font customization, scaling, multi-monitor and accessibility. Do not ship a renamed theme or static mockup.

Exit criteria: Classic is a selectable functioning session; controls, navigation, persistence, keyboard access, scaling and multi-monitor behavior pass interaction tests.

### STAGE 4 — NEXORA Flow desktop
**Status: QUEUED**

Implement a distinct workspace-oriented desktop: workspace dashboard, dock/panels, full-screen launcher, global app/file search, workspace/window overview, tiling/split layouts, widgets with real data, focus mode, quick settings, modern notifications, multi-display workspaces, themes and reduced-motion support.

Exit criteria: Flow is independently selectable and behaviorally distinct; workspace/window/widget actions and preference persistence pass tests.

### STAGE 5 — Safe installer and dual-desktop installation
**Status: QUEUED**

Complete Calamares runtime integration and branding. Implement language/accessibility/keyboard/network, disk selection, blank/alongside/manual partitioning, clear change preview, final confirmation, user/device/time zone, desktop default, progress and reboot. Install one shared base containing both Classic and Flow. Preserve existing EFI/data on supported alongside installs. Keep encryption disabled until full LUKS2 boot/recovery qualification.

Exit criteria: clean install, alongside Windows/Linux preservation, manual partitioning, cancellation, interruption/failure recovery and both-session selection pass on disposable VM disks under supported firmware. No destructive test on user disks.

### STAGE 6 — Welcome Center, Control Center, Application Center and core utilities
**Status: QUEUED**

Implement first-boot Welcome Center and reopenable checklist; centralized working settings for personalization, system, network, devices, security/privacy and maintenance; app discovery and real APT/Flatpak install/update/uninstall with origin/trust/permissions; diagnostics; file management; browser, editor, PDF, archive, calculator, screenshot, media and terminal essentials. All controls must operate on real system state.

Exit criteria: all exposed controls and package/file workflows work end-to-end; errors are handled; diagnostics are accurate and redact secrets by default.

### STAGE 7 — Security, privacy, updates, backup and recovery
**Status: QUEUED**

Harden AppArmor, firewall, least privilege/polkit, signed repositories and package trust, Secure Boot signing/enrollment, privacy controls and LUKS2 encryption/recovery. Implement update history, safe update transactions, failed-update recovery, backup to external media, scheduled/incremental/encrypted backup, integrity checks, file/system restore, safe mode and boot repair.

Exit criteria: threat review, Secure Boot (if advertised), encrypted boot/wrong-key/recovery, signed update, failed update, backup integrity and restoration tests pass. Do not advertise untested protections.

### STAGE 8 — Hardware, networking, accessibility and performance qualification
**Status: QUEUED**

Test AMD/Intel CPUs; Intel/AMD/NVIDIA graphics; Wi-Fi/Ethernet/Bluetooth; NVMe/SATA/HDD; audio, webcam/mic, USB, printers/scanners, displays, keyboard/touchpad, battery and suspend/resume. Validate screen reader, magnifier, keyboard navigation, contrast, scaling, captions and reduced motion. Benchmark boot, RAM/CPU, application start, GPU and battery before optimizing.

Exit criteria: publish a truthful device/model/kernel/driver/firmware compatibility matrix and performance measurements, with known limitations.

### STAGE 9 — Optional gaming, creator, developer, education and business packs
**Status: QUEUED**

Provide opt-in trusted package packs: Steam/Proton and optional launchers/controllers/GameMode/MangoHud; Blender/OBS/Kdenlive/Krita/GIMP/Audacity and media tools; Git, Python, C/C++, Java, Node, Rust, PHP, IDEs, databases, containers and developer tooling; optional education/business/technical collections. Avoid bloating the base system and avoid unsupported compatibility claims.

Exit criteria: every advertised pack installs, launches, updates and uninstalls; provenance, licenses, resource needs and compatibility are documented.

### STAGE 10 — Final QA, documentation, governance and NEXORA OS 1.0 release
**Status: QUEUED**

Run the complete regression and release acceptance matrix across image, BIOS/UEFI/USB/optical, installer, both desktops, services, applications, security, updates, backup/recovery, hardware, accessibility and performance. Complete user/developer docs, changelog, known issues, SBOM, release signing, checksums, support policy, branch protection and owner-approved license.

Exit criteria: every mandatory release check passes on a named commit and signed ISO checksum; critical defects are resolved; known limitations are published. Do not release based on planned work or partial CI.

## Current stage checkpoint

- Active stage: Stage 1 — Bootable build foundation.
- Active product code branch: `fix/snapshot-package-index-fallback`.
- Open integration PR: [PR #5](https://github.com/ravaunrichards/NEXORA-OS-1.0/pull/5).
- Latest PR head at checkpoint: `e7bb3666fc4613a0dc1b1167a4dde45b5dfe2946`.
- Latest successful targeted checks: repository validation #318 and Ubuntu live-build probe #59 on the latest PR head.
- Full build #63 failed due the legacy `rsvg` renderer; build #65 is still running on an older source and #69 is queued with the tested SVG and Casper overlay fixes. Do not start another competing full ISO build while either occupies the branch's build concurrency group.
- Immediate next action: leave #70 running without cancellation or a competing build; refresh its run/job/artifact state. Once it completes, retrieve the uploaded full build log and exact artifact, verify the image and SHA-256, then inspect/execute the four firmware/media boots against that exact artifact. Keep older #65 and queued #69 untouched.
- Main remains unchanged at `d8b2085122e094b514caf803921385d57ec435f7`.
- No license or main-branch protection setting has been changed; both require owner decisions/actions.

## Stage completion record

| Stage | State | Evidence |
|---|---|---|
| 1. Bootable build foundation | IN PROGRESS | Validation #319 passed on `6c65da37022b23c8891d2392b0a2511ec34297bd`; live-build probe #59 passed on `e7bb3666fc4613a0dc1b1167a4dde45b5dfe2946`; run #70 (`42999044714`), job `130450283455`, step 4 ISO generation active; no artifact yet; SHA-256 and four real-image boots pending |
| 2. Shared core OS | QUEUED | — |
| 3. NEXORA Classic | QUEUED | — |
| 4. NEXORA Flow | QUEUED | — |
| 5. Installer | QUEUED | — |
| 6. Welcome/settings/app center/utilities | QUEUED | — |
| 7. Security/updates/backup/recovery | QUEUED | — |
| 8. Hardware/accessibility/performance | QUEUED | — |
| 9. Optional application packs | QUEUED | — |
| 10. Final QA and release | QUEUED | — |
