# Hypratomic roadmap

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
Hardware acceptance remains required before declaring Phase 2 complete. See
[the validation checklist](docs/phase2-validation.md).

Goal: make the desktop *behave* like Omarchy while keeping the shell simple.

- Add split Hyprland configuration.
- Port/adapt keybindings and workspace behavior.
- Add terminal/file-manager/browser variables.
- Add screenshot/clipboard bindings.
- Add idle/lock behavior.
- Keep monitor configuration in a separate user-owned file.
- Keep Waybar as the bar.
- Add an activation/deactivation helper with backups.

Implementation: upstream Lua modules under `/usr/share/hypratomic/hypr/`,
Foot and Yazi defaults, separate user overrides,
`hypratomic-activate` / `hypratomic-restore`, Wayblue session integration with
Waybar, and isolated recovery tests. Activation saves the working configuration
before changes; restoration uses the latest activation cycle's recovery point.
Repeated activation preserves that point. Deployment and login never activate
the profile automatically. Quickshell remains unactivated.

Validation: ShellCheck and Bash syntax checks passed, all 37 isolated tests
passed, `bluebuild validate recipes/recipe.yml` passed, and
`bluebuild build --build-driver docker recipes/recipe.yml` produced
`localhost/hypratomic:latest`. The image validated its Lua configuration and
exercised the installed activation/restoration commands in a disposable home.
The recipe continues to track Wayblue `latest`; obsolete `.conf` support was
removed instead of downgrading the compositor or base image.

Exit criterion: Hyprland behavior is stable and can be disabled in one command.

## Phase 3 — Omarchy-inspired visual layer

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

Goal: replace the collection of small desktop daemons with a coherent shell.

- Status bar.
- Launcher.
- Notifications.
- OSD.
- Power/session UI.
- Polkit surface if appropriate.
- Network/Bluetooth controls.
- Theme integration.
- Only then disable Waybar and any replaced services.

Exit criterion: Quickshell is the normal daily shell and Waybar remains an
available emergency fallback.

## Phase 5 — Applications and polished distribution

- Flatpak policy and default applications.
- Toolbx/Distrobox development containers.
- Optional local development tooling.
- Hardware-specific variants only if actually needed.
- ISO generation.
- Upgrade policy and release tags.
