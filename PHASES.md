# Hypratomic roadmap

The goal is a reproducible, recoverable, rebuildable workstation that can be set
up quickly on supported hardware. Fedora Atomic and current Wayblue provide the
foundation; desktop/editor settings, project environments, AI integration, and
user data are separate layers with their own setup and recovery paths.

Follow current upstream while recording validated image digests, recipe revisions,
and dependency locks. Fresh-machine provisioning and recovery are acceptance
criteria; a moving `latest` tag or a successful image build alone is insufficient.
The coding and data phases below are planned work, not installed features or
selected products.

The execution order keeps host-image development together: first the base,
Hyprland configuration, coding surface, visual layer, and shell. Project
environments, AI, and user-data services follow as independent user-space
layers; they are not added to the host image.

## Phase 1 — Proven bootable base (this repository)

Status: complete. The custom image, Hyprland session, rebase, and rpm-ostree
rollback have been tested on real hardware. Foot is the standard terminal;
Kitty native-Wayland troubleshooting is out of scope.

Goal: prove the custom image is boring and recoverable.

- Base on Wayblue Hyprland.
- Add Quickshell without activating it.
- Add only a small CLI/terminal baseline.
- Keep Wayblue Waybar/configuration as the working fallback.
- Build and sign the image.
- Rebase a test machine.
- Verify two successful boots.
- Verify `rpm-ostree rollback` before customizing the desktop.
- Run `hypratomic-doctor`.

Exit criterion: you would be comfortable using this image for a week even if
we stopped the project here.

## Phase 2a — Explicit, recoverable Hyprland configuration

Status: Phase 2a implemented and local Docker image build passed on 2026-09-19.
On 2026-09-20 the user confirmed desktop operation, restoration, and reactivation
on hardware. Kitty remained problematic; the image now removes Kitty and uses
Foot in Wayblue's system fallback as well. Hardware verification of this terminal
change remains pending; other detailed acceptance checks are not inferred from
that report. See
[the validation checklist](docs/phase2-validation.md).

Goal: make the desktop *behave* like Omarchy while keeping the shell simple.

- Add split Hyprland configuration.
- Port/adapt keybindings and workspace behavior.
- Add terminal/file-manager/browser variables.
- Add screenshot/clipboard bindings.
- Add idle/lock behavior.
- Keep monitor configuration in a separate user-owned file.
- Keep Waybar as the bar.
- Provide live Hyprland and Tmux keybind lists without requiring Quickshell.
- Add an activation/deactivation helper with backups.

Implementation: upstream Lua modules under `/usr/share/hypratomic/hypr/`,
Foot and Yazi defaults, separate user overrides,
`hypratomic-activate` / `hypratomic-restore`, Wayblue session integration with
Waybar, and isolated recovery tests. Activation saves the working configuration
before changes; restoration uses the latest activation cycle's recovery point.
Repeated activation preserves that point. Deployment and login never activate
the profile automatically. Quickshell activation is handled by the session layer
and is tracked in Phase 4.

Validation: ShellCheck and Bash syntax checks passed, all 37 isolated tests
passed, `bluebuild validate recipes/recipe.yml` passed, and
`bluebuild build --build-driver docker recipes/recipe.yml` produced
`localhost/hypratomic:latest`. The image validated its Lua configuration and
exercised the installed activation/restoration commands in a disposable home.
The recipe continues to track Wayblue `latest`; obsolete `.conf` support was
removed instead of downgrading the compositor or base image.

Exit criterion: Hyprland behavior is stable and can be disabled in one command.

## Phase 2b — Terminal coding workflow and keybinding audit

Status: Tmux/Neovim baseline and live keybind viewer implemented; the
[ownership and audit procedure](docs/phase2b-keymap.md) is documented, while
hardware workflow validation remains.

Goal: Neovim/LazyVim inside Tmux or Herder, running in Foot on Hyprland, with an
Omarchy-inspired workflow and no competing shortcuts between layers.

- Use Tmux as the initial supported multiplexer; compare it with Herder for session
  recovery, pane navigation, agent workflows, maintenance, and compatibility with
  current upstream versions before adding Herder support.
- Include Neovim and a reversible `hypratomic-coding-bootstrap` command that
  preserves existing Tmux files and records plugin/tool versions.
- Publish a binding ownership table: Hyprland uses Super; Foot preserves application
  input; the multiplexer owns its prefix; Neovim owns modal/leader commands.
- Audit direct multiplexer shortcuts, LazyVim mappings, shell controls, and the AI
  leader subgroup together. Preserve upstream defaults where they do not conflict.
- Test normal/insert/terminal/copy modes, nested sessions, SSH, clipboard handling,
  and navigation across editor splits and multiplexer panes.

Exit criterion: a fresh user can reproduce the coding setup, navigate the complete
stack without intercepted shortcuts, and restore their previous configuration.
Record the tested keymap; do not claim conflict-free behavior from the compositor
configuration alone.

## Phase 3 — Omarchy-inspired visual layer

Status: complete on 2026-09-21. Palette, coding/Nerd fonts, Foot/GTK themes,
wallpaper selection, blacklist/replacement, and runtime border colors were
validated on hardware. Quickshell is now the default shell; Waybar remains the
explicit recovery fallback.

Goal: reproduce the visual language without importing Arch assumptions.

- Fonts and Nerd Fonts.
- Cursor/icon/GTK choices.
- Wallpaper handling.
- Foot theme.
- Hyprland colors, gaps, borders, animations.
- Central palette file and generated application theme fragments.
- One initial theme before supporting multiple themes.

Exit criterion: screenshots should look recognizably Omarchy-inspired while
remaining native to Fedora.

## Phase 4 — Quickshell / Quattro-style shell

Status: started. Quickshell is now the default shell with Walker launcher,
notification toast, and power/session menu; OSD remains.

Goal: replace the collection of small desktop daemons with a coherent shell.

- Status bar.
- Launcher.
- Notifications.
- OSD.
- Power/session UI.
- Polkit surface if appropriate.
- Network/Bluetooth controls.
- Theme integration.
- Keep Waybar as an explicit recovery fallback while validating the replacement
  surfaces.

Exit criterion: Quickshell is the normal daily shell and Waybar remains an
available emergency fallback.

## Phase 5 — Rebuildable project environments

Status: planned; environment manager not yet selected.

Goal: a short path from cloning a project to a working Rust or
TypeScript/JavaScript development environment without per-project host layering.

- Evaluate Toolbx/Distrobox/devcontainers, DevPod (`devpod.sh`), and optional
  Nix flakes/dev shells; select one simple default with an explicit
  Atomic-compatible setup/removal path.
- Supply project templates with toolchain versions, image digests or flake locks,
  dependency locks, service definitions where needed, and build/test commands.
- Resolve editor/LSP/formatter/debugger placement and ensure agent commands run
  with the same tools, working directory, and permissions as interactive commands.
- Document shared-home access, mounted paths, UID ownership, caches, downloads,
  offline limits, and dependency isolation versus security boundaries.
- Test multiple projects with different toolchain versions and recreation after
  removing their environments while preserving all source and uncommitted work.

Exit criterion: Rust and TypeScript/JavaScript samples build and test on a second
clean machine using recorded definitions, with working editor language support
and no manual host package drift.

## Phase 6 — AI threads and agents in Neovim

Status: planned. Plugin, history storage, and default model/provider remain open.

Goal: a Zed-like threads/agents workflow inside Neovim/LazyVim with optional local
Ollama or remote AI, without making the editor depend on either.

- Evaluate CodeCompanion and alternatives against multiple project-scoped threads,
  selected-file context, persistent/resumable history, agent progress/cancellation,
  and review/accept/reject/undo of edits. Do not assume full Zed parity.
- Test both an Ollama model and a remote provider, including the actual model's
  tool-use abilities; document hardware, download, and CPU/remote fallback limits.
- Run agent tools in the selected project environment with reviewable command and
  file access, and integrate shortcuts with the Phase 2b binding audit.
- Keep credentials, model caches, and histories outside tracked configuration and
  image layers; make source transmission to remote providers explicit.
- Verify provider switching, unavailable-provider behavior, and normal offline
  editing. Define which conversation history is included in user backups.

Exit criterion: a user can switch local/remote providers, resume a project thread,
review and undo agent edits, run project tests, and keep editing during an outage.

## Phase 7 — Self-hosted user files and independent backups

Status: planned. Seafile/SeaDrive and Nextcloud are candidates; no service is selected.

Goal: a separate user-data layer with OneDrive-like background sync and Linux
files-on-demand, plus recovery independent of OS rollback and the sync service.

- Prototype both candidates on Fedora Atomic/Hyprland with Yazi, Neovim, and CLI
  access. Verify actual Linux virtual-file support and packaging/FUSE requirements.
- Test opening remote-only files, offline pinning, cache eviction, offline writes,
  conflicts, renames/deletions, symlinks/permissions, reconnects, and large files.
- Make synchronization status and failures visible. Define recovery-point and
  recovery-time targets rather than promising zero-loss real-time backup.
- Keep active worktrees local unless file watching, locking, and offline behavior
  are proven suitable. Include uncommitted work in the recovery plan.
- Add independently retained, versioned backups with encryption, retention,
  separate key recovery, and explicit handling of server data/database/configuration.
  Client placeholders and synchronized deletions must not defeat recovery.
- Define backup inclusion/exclusion rules: preserve personal files, selected
  configuration and recovery records; exclude regenerable dependencies, build
  outputs, downloaded models, and container layers by default.
- Document provisioning and maintaining the self-hosted server separately from
  enrolling or replacing a desktop client.

Exit criterion: demonstrate recovery of an earlier/deleted file, offline edits
through a reconnect, and recovery after both client-disk loss and server loss.
Verify remote file contents are backed up, not just placeholder names.

## Phase 8 — Applications and polished distribution

- Flatpak policy and default applications.
- Integrate the validated coding, environment, AI, and data layers into onboarding.
- Record release image digests, source revisions, dependency locks, and recovery instructions.
- Time a fresh-machine setup through restoring files and running a project test.
- Hardware-specific variants only if actually needed.
- ISO generation.
- Upgrade policy and release tags.

Exit criterion: provision a supported replacement machine from documented inputs,
restore configuration and personal files, recreate a project environment, and
resume coding without undocumented changes to the host.
