# NEXORA OS — master stage queue

All requirements from the NEXORA OS 1.0 product and engineering brief must map to a stage below. Stage status is factual and acceptance-driven. Work one active stage at a time; a blocked stage retains its requirements and is never marked completed.

## S00 — Repository identity, recovery and execution records
**Status: COMPLETED**  
**Objective:** Lock execution to the correct repository, recover the actual checkpoint, and establish auditable progress records.  
**Dependencies:** None.  
**Requirements/tasks:** Verify owner/repository/ID/remote/default branch/active branch/commit; inspect tree and previous agent records; preserve pre-existing work; record workspace constraints; create identity, progress, queue, decision and blocker files.  
**Acceptance:** Repository and branch refs match GitHub metadata; records are committed in this repository; no unrelated repository was accessed for project changes.  
**Evidence:** Repository `ravaunrichards/NEXORA-OS-1.0`; active branch `fix/snapshot-package-index-fallback`; baseline HEAD `366d0ab2330725a55682906c01303b53815c526d`.

## S01 — Ubuntu 26.04 AMD64 live-image foundation
**Status: IN PROGRESS**  
**Priority:** CRITICAL.  
**Objective:** Generate and verify a real NEXORA engineering ISO on Ubuntu 26.04 LTS AMD64, without changing the target distribution to avoid build errors.  
**Dependencies:** None; blocks all install/desktop acceptance.  
**Requirements/tasks:**
- Preserve Ubuntu 26.04 Resolute, AMD64/x86-64 and signed Ubuntu archive metadata.
- Stabilize the live-build/debootstrap pipeline and keep the dated snapshot, signed Release metadata and package identity pinned.
- Keep any transport fallback narrowly scoped to exact relative paths and require debootstrap checksum/size verification.
- Resolve obsolete Syslinux theme/gfxboot package requests; explicitly verify bootloader configuration and live-build package/module behavior against Resolute.
- Preserve Ubuntu APT pocket naming in generic mode: keep resolute-updates enabled using exported LB_UPDATES=true; disable only Debian-mode automatic security-source generation; add signed resolute-security from the selected snapshot for build time and security.ubuntu.com resolute-security for the installed OS.
- Test the generated .list.chroot and .list.binary sources, the Ubuntu archive key path and the absence of the invalid resolute/updates suite.
- Explicitly stage BIOS ISO boot assets into the local live-build configuration before `lb config`: templates from `/usr/share/live/build/bootloaders/isolinux`, `isolinux.bin` from package `isolinux`, and the required BIOS modules `ldlinux.c32`, `libcom32.c32`, `libutil.c32` and `vesamenu.c32` from `syslinux-common`.
- Install the `isolinux` and `syslinux-common` host packages explicitly; test every staged module with synthetic files and probe the actual Resolute package file locations.
- Retain the explicit supported Ubuntu firmware metapackage; prevent legacy firmware auto-injection and outdated memtest filename assumptions.
- Preserve Casper live boot, the Ubuntu kernel and the shared KDE Plasma base.
- Resolve package manifest/dependency failures and any new errors from the actual build logs.
- Generate an ISO without overwriting existing artifacts; retain build inputs, logs and workspace.
- Verify filesystem/El Torito BIOS and UEFI entries, hybrid EFI MBR marker, fallback EFI loader, and SHA-256.
- Boot the actual image under BIOS and UEFI, from optical and USB media, using QEMU; preserve serial logs, commit, snapshot, artifact and checksum.
- Document what synthetic tests do and do not prove.
**Acceptance:** Successful full build on supported Ubuntu 26.04 AMD64 host; target image identity verified as Ubuntu 26.04; ISO and checksum created; structural verifier passes; four firmware/medium smoke tests reach live userspace. Secure Boot remains separately gated.  
**Next implementation tasks:** Complete full ISO build #56/#58 with split-package ISOLINUX staging; fix the next observed build failure; then verify ISO SHA-256/structure and run the four QEMU BIOS/UEFI optical/USB cases.

## S02 — Shared operating-system foundation and services
**Status: NOT STARTED**  
**Priority:** CRITICAL.  
**Objective:** Establish the common installed OS and reliable Plasma-based desktop foundation shared by Classic and Flow.  
**Dependencies:** S01.  
**Requirements/tasks:**
- Verify boot, login, SDDM, Plasma session startup/shutdown and a shared user account/home directory.
- Integrate and test NetworkManager, Wi-Fi, Ethernet, Bluetooth, PipeWire/WirePlumber, audio, camera, display, USB, storage and printer/scanner services.
- Verify graphics stacks and AMD/Intel/NVIDIA driver options; keep proprietary drivers optional and license-aware.
- Confirm a single installed application collection, shared network/audio/Bluetooth configuration, update service, driver state, security framework and backup/recovery framework.
- Validate kernel, system services, system clock, locale/time zone, suspend/resume and power settings.
- Define stable integration boundaries so desktop experience packages do not duplicate hardware services or privileged managers.
- Keep default resource use reasonable; measure rather than claim performance.
**Acceptance:** Repeated clean boots/logins and session transitions succeed in supported VMs; core services report real device state and work; shared account/data/services are proven.

## S03 — NEXORA Classic desktop
**Status: NOT STARTED**  
**Priority:** HIGH.  
**Objective:** Implement a familiar, configurable traditional desktop, not a renamed static Plasma theme.  
**Dependencies:** S02.  
**Requirements/tasks:**
- Traditional desktop layout, desktop icons and wallpaper management.
- Application/start menu, searchable app launcher, pinned apps and shortcuts.
- Taskbar, configurable panels, system tray and notification center.
- File manager and file-preview integration.
- Window management, move/resize, snapping, multiple virtual desktops and window switching.
- Quick settings, keyboard shortcuts, multi-monitor layout and scaling.
- Light/dark themes, NEXORA icons, fonts, colors and login/lock-screen appearance.
- Accessibility, keyboard navigation, high contrast, font scaling, screen reader and reduced-motion support.
- Define independent Classic configuration and migration/reset behavior without duplicating user accounts or application installs.
**Acceptance:** Classic is independently selectable, all primary controls work, responsive layouts avoid overlap/clipping, preferences persist, keyboard and accessibility tests pass.

## S04 — NEXORA Flow desktop
**Status: NOT STARTED**  
**Priority:** HIGH.  
**Objective:** Build a distinct modern, workspace-oriented desktop experience.  
**Dependencies:** S02.  
**Requirements/tasks:**
- Modern workspace dashboard and configurable workspace panels.
- Full-screen launcher and search across apps/files.
- Workspace and virtual-desktop navigation, app switching and modern window overview.
- Multi-window arrangements, snapping and multiple-display workspaces.
- Widgets with real data sources and clear permissions.
- Contextual quick settings and modern notifications.
- Focus mode, productivity layouts, personalization and light/dark/automatic themes.
- Smooth, restrained transitions that respect reduced-motion and hardware capability.
- Separate Flow settings and layouts while sharing OS services, files, account and apps with Classic.
**Acceptance:** Flow is independently selectable and functional; workspace/window/widget actions work; preferences persist; no static mockups, overlap or inaccessible navigation.

## S05 — Safe Calamares installation and dual-desktop selection
**Status: NOT STARTED**  
**Priority:** CRITICAL.  
**Objective:** Deliver a real, safe installer for one OS installation containing both desktop experiences.  
**Dependencies:** S01, S02, S03 and S04 (the installer must not offer Classic/Flow selection until both installable sessions exist).  
**Requirements/tasks:**
- Finish Calamares runtime integration, module/package configuration and branding.
- Flow: welcome, language, accessibility, keyboard, network, target, partitioning, preview, optional encryption, user/device/time zone, desktop default, final review, explicit confirmation, progress, completion/reboot.
- Support selected-disk install, alongside an existing supported OS, and manual partitioning.
- Show disk model/capacity/path and every affected partition; never infer a disk by order/size.
- Never write/format/resize before final confirmation; require an additional confirmation for destructive partition changes.
- Preserve existing EFI partitions for supported alongside installs; abort ambiguous disk/boot/partition states.
- Disable automated LUKS until full boot/recovery qualification passes.
- Test only on disposable VM disks or explicitly designated test hardware; never run destructive tests against a user disk.
- Install shared base once, one user account/home, both sessions; choose initial default and permit switching at login.
- Preserve diagnostic logs and pre-install partition inventory; test cancellation and interruption.
**Acceptance:** Pass blank-disk, alongside Windows/Linux, manual partition, cancellation, failure/recovery and desktop-selection matrix under BIOS/UEFI where supported; demonstrate preservation. No real-disk install before evidence.

## S06 — Welcome Center, Settings, Application Center and Diagnostics
**Status: NOT STARTED**  
**Priority:** HIGH.  
**Objective:** Implement cohesive system management utilities backed by real OS APIs and package managers.  
**Dependencies:** S02; S03/S04 for desktop integration.  
**Requirements/tasks:**
- Welcome Center first-boot checklist: desktop choice, connectivity, language/keyboard/region, display/audio/accessibility, privacy, updates, drivers, applications, backup and recovery; allow skip/reopen.
- Centralized settings categories: Personalization; System; Network and connectivity; Devices; Security and privacy; Maintenance.
- Implement actual settings for themes, wallpaper, colors/icons/fonts, layouts, login/lock screen, display scaling/animation, device/kernel/storage/process/startup/power/services, Wi-Fi/Ethernet/Bluetooth/VPN/proxy, displays/input/printers/scanners/audio/camera/USB, firewall/accounts/password/encryption/privacy/permissions, updates/apps/drivers/storage cleanup/backup/recovery/logs/diagnostics.
- Application Center using signed Ubuntu APT repositories and Flatpak with visible origin/trust/sandbox/permissions, category discovery, descriptions/screenshots/version, install/update/uninstall/dependencies/history/error handling.
- Essentials: browser, file manager, editor, PDF viewer, archives, calculator, screenshot, media, terminal, image viewer; optional packs for LibreOffice, calendar, mail, notes and communication.
- System diagnostics: OS/kernel/CPU/memory/storage/GPU/network/driver/audio/boot/Secure Boot/encryption/update/error state; redact sensitive details unless explicitly included.
- No fake installation buttons or nonfunctional settings.
**Acceptance:** All exposed controls change real system state or clearly explain unsupported hardware; install/manage/uninstall flows work; diagnostics are accurate and redact secrets.

## S07 — Security, privacy, Secure Boot and encryption
**Status: NOT STARTED**  
**Priority:** CRITICAL.  
**Objective:** Establish secure defaults and demonstrate the complete trusted boot, access and encryption paths before advertising support.  
**Dependencies:** S01 and S02; installer integration for disk encryption tests.  
**Requirements/tasks:**
- AppArmor enforced profiles and audit policy; UFW firewall defaults with documented exceptions.
- Signed APT/Flatpak trust, metadata verification, security update configuration, least privilege and polkit administration prompts.
- UEFI Secure Boot support with signed shim/kernel/GRUB chain, documented signing/enrollment/key custody and recovery tests.
- User account password protection, screen lock, permission visibility and session protection.
- Privacy controls: no mandatory cloud account, no hidden telemetry, optional diagnostics, clear camera/mic access, secure local information.
- LUKS2 full-disk/root encryption, recovery key/passphrase guidance, boot unlock, safe shutdown and end-to-end recovery; EFI remains boot-compatible and unencrypted as appropriate.
- Vulnerability and dependency review, secret scanning and supply-chain safeguards.
**Acceptance:** Threat model/security review and reproducible automated/manual tests pass; no Secure Boot or encryption claim before clean VM boot, wrong-key and recovery tests.

## S08 — Update Center, backup and recovery
**Status: NOT STARTED**  
**Priority:** CRITICAL.  
**Objective:** Keep the OS current and recoverable without silently losing applications or data.  
**Dependencies:** S02 and S07; installer/storage architecture as needed.  
**Requirements/tasks:**
- OS/security/kernel/application/driver update discovery, notifications, progress, restart requirements, history and useful errors.
- Verify signed repository metadata and packages; optional configurable automatic security updates.
- Safe update transaction behavior and failed-update recovery/previous-kernel selection.
- External-drive and scheduled/manual backups; incremental and encrypted options; backup integrity verification.
- Restore individual files, preferences and system data; recovery environment, restore points and clear guidance.
- Select ext4 as conservative default unless full Btrfs snapshot/rollback design and recovery are verified.
- Protect documents/settings; no unsafe automatic cleanup or destructive restore.
**Acceptance:** Update, interrupted/failed update recovery, backup, integrity verification and restore test cases demonstrate preserved user files/settings.

## S09 — Hardware, network, accessibility and performance qualification
**Status: NOT STARTED**  
**Priority:** HIGH.  
**Objective:** Publish an honest AMD64 compatibility matrix and measurable system quality.  
**Dependencies:** S01 and S02; desktop sessions for UI/accessibility tests.  
**Requirements/tasks:**
- Test Intel/AMD CPU, Intel/AMD/NVIDIA graphics, Wi-Fi/Ethernet/Bluetooth, NVMe/SATA/HDD, audio, webcams/microphones, USB, printers/scanners, external/multiple displays, touchpads/keyboards and laptop battery.
- Verify suspend/resume, thermal/power handling, network diagnostics, saved networks, VPN/proxy, mobile broadband where hardware supports.
- Accessibility: screen reader, magnification, high contrast, font sizes, keyboard navigation, on-screen keyboard, reduced motion, captions, screen scaling and accessible installer/login/notifications.
- Performance: startup time, CPU/RAM/disk use, application startup, GPU, battery, indexing and background services; optimize only with baseline measurements.
- Publish device/model/kernel/driver/firmware and test-result evidence.
**Acceptance:** Repeatable hardware matrix with environment and limitation notes; no unsupported device is claimed compatible.

## S10 — Optional application and specialist packs
**Status: NOT STARTED**  
**Priority:** MEDIUM.  
**Objective:** Provide opt-in gaming, creator, developer, education, business and technical tools without bloating the base installation.  
**Dependencies:** S02 and S06; S09 for hardware-specific compatibility notes.  
**Requirements/tasks:**
- Gaming: Steam/Proton, optional Lutris and Heroic, controllers, GPU driver status, library management, GameMode, MangoHud, performance/audio profiles; communicate game compatibility limitations.
- Creator: Blender, OBS Studio, Kdenlive, Krita, GIMP, Audacity, media processing, streaming, storage, camera/microphone and studio layout.
- Developer: Git, Python, C/C++, Java, Node.js, Rust, PHP, database tools, IDE/code editor, terminal, SSH and Podman/Docker option.
- Education/business and technical software collections as useful, optional packs.
- Ensure packages are sourced from trusted repositories, show licenses/origins and offer clean removal.
**Acceptance:** Every pack installs, launches, updates and uninstalls successfully; no false compatibility promises or default software overload.

## S11 — System-wide QA, documentation and release qualification
**Status: NOT STARTED**  
**Priority:** CRITICAL.  
**Objective:** Prove Version 1.0 against the release acceptance matrix.  
**Dependencies:** S01–S10.  
**Requirements/tasks:**
- Automated build/package/manifest tests; image checksums and filesystem/El Torito inspection.
- BIOS/UEFI/USB/optical/Live desktop tests; Secure Boot only if qualified.
- Installer blank/alongside/manual/encrypted/cancel/failure tests on disposable VM disks.
- Classic/Flow startup, switching, layout, application, scaling and multi-monitor tests.
- Network/audio/Bluetooth/GPU/storage/suspend/restore/accessibility and app lifecycle tests.
- Security, updates, backup, recovery, upgrade and data-preservation tests.
- Evidence bound to source commit, Ubuntu snapshot, image SHA-256, VM/physical hardware environment, logs and results.
- User/technical docs: overview, requirements, download/install/dual-boot/encryption, Classic/Flow guides, apps, updates, drivers, network, customization, security/privacy, backup/recovery, troubleshooting, hardware matrix, developer docs and release notes.
- Create versioned changelog, known issues, build inputs, SBOM, signing and checksums.
**Acceptance:** Every required checklist entry passes with evidence; critical defects resolved; release artifacts independently verifiable and signed; no missing/untested feature is described as complete.

## S12 — Governance, supply-chain and long-term maintenance
**Status: NOT STARTED**  
**Priority:** HIGH.  
**Objective:** Protect the repository, document ownership/legal choices and maintain trustworthy build pipelines.  
**Dependencies:** S00; release processes are aligned with S11.  
**Requirements/tasks:**
- Protect main branch; require PR and successful validation, resolved conversations; prevent force-push/deletion; keep admin override policy reasonable.
- CODEOWNERS, focused branches, PR reviews, contribution guidance and security reporting.
- Decide and document project license explicitly; until then, do not assume public source can be redistributed.
- Review GitHub Actions permissions, pinned action revisions, dependency updates and security alerts.
- Generate and retain SBOMs; scan dependencies and artifacts; keep secrets/signing keys out of Git.
- Stable/testing/development channels, version/tag process, signed artifacts, checksums, release provenance and documented support lifecycle.
**Acceptance:** Repository rules are read back and verified; license is owner-approved and included; CI security and supply-chain checks are documented and pass. Owner-only actions remain BLOCKED until authorized; never mark them complete based on instructions alone.

## Queue policy

- Exactly one implementation stage may be active at a time.
- A stage moves to COMPLETED only after its listed acceptance checks pass with recorded evidence.
- A blocked stage remains in the queue and is not counted as complete.
- Do not remove user requirements; revise stages only with a recorded decision.
- At each stage checkpoint update MASTER_PROGRESS.md, DECISIONS.md, BLOCKERS.md and this queue.
