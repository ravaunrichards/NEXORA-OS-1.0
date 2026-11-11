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

Current evidence (2026-11-11, refreshed 07:20 UTC):
- Repository validation #296 passed on commit `17430d7fa7f74a3c79564825bab598d597eca33d`. The Casper/Syslinux regression now covers the common-library include and verifies the original package script remains unchanged.
- Ubuntu live-build configuration probe #50 passed on commit `17430d7fa7f74a3c79564825bab598d597eca33d`. It uses the actual Ubuntu Resolute live-build package, creates the private overlay, and confirms the `lb` dispatcher executes the private override. Probe #49 also passed for the common-library correction.
- Full builds #61 and #62 failed on their respective older commits at the overlay bootstrap: the copied stage script attempted to source the nonexistent `/usr/lib//build.sh`. Both reached Syslinux after package installation; neither produced an ISO.
- The overlay now explicitly binds its copied Syslinux stage to Ubuntu's packaged common library at `/usr/lib/live/build.sh`, while retaining the Casper kernel/initrd rewrite. The include is protected from the broad `/live/` path substitution. The regression fixture now deliberately supplies a common-library path containing `/usr/lib/live/` to catch that regression.
- The ISO workflow path filters now include both `build/prepare-casper-syslinux-overlay.sh` and `build/test-casper-syslinux-overlay.sh`, so future changes to the actual builder helper or its test trigger a full ISO run.
- Full build #63 is `in_progress` on PR branch commit `1b581237e66a6a3d5b0b0e16b86ae5a6dc2e9563`. It is the first complete build to include the common-library fix and the corrected workflow triggers.
- After an ISO succeeds, the firmware workflow must still verify the exact artifact SHA-256/structure and all four BIOS/UEFI optical/USB boots.
- No successful ISO artifact, checksum, or real-image boot result has been verified. Therefore Stage 1 remains IN PROGRESS; Stages 2–10 remain QUEUED.

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
- Latest PR head at checkpoint: `1b581237e66a6a3d5b0b0e16b86ae5a6dc2e9563`.
- Latest successful targeted checks: repository validation #296 and Ubuntu live-build probe #50 on commit `17430d7fa7f74a3c79564825bab598d597eca33d`.
- Full builds #61 and #62 failed before producing an ISO; their common-library bootstrap failure has been corrected. Full build #63 is now in progress on the latest PR head. Do not start a competing full ISO build while #63 occupies the branch's build concurrency group.
- Immediate next action: inspect #63's build log/artifact when it completes; fix only evidence-backed blockers; then verify the real image and run its four firmware/media boots.
- Main remains unchanged at `d8b2085122e094b514caf803921385d57ec435f7`.
- No license or main-branch protection setting has been changed; both require owner decisions/actions.

## Stage completion record

| Stage | State | Evidence |
|---|---|---|
| 1. Bootable build foundation | IN PROGRESS | Validation #296 and live-build probe #50 pass; full build #63 in progress; ISO checksum and four real-image boots still pending |
| 2. Shared core OS | QUEUED | — |
| 3. NEXORA Classic | QUEUED | — |
| 4. NEXORA Flow | QUEUED | — |
| 5. Installer | QUEUED | — |
| 6. Welcome/settings/app center/utilities | QUEUED | — |
| 7. Security/updates/backup/recovery | QUEUED | — |
| 8. Hardware/accessibility/performance | QUEUED | — |
| 9. Optional application packs | QUEUED | — |
| 10. Final QA and release | QUEUED | — |
