# Hypratomic

A BlueBuild Fedora Atomic image based on Wayblue Hyprland, with an
Omarchy-inspired keyboard workflow and a recoverable desktop configuration.
Foot is the standard terminal; Yazi is the default file manager. Waybar remains
the active bar; Quickshell is installed for future work but is not started.

Phase 1 builds, boots, rebases, and OS rollback have been tested on hardware.
See [PHASES.md](PHASES.md) for milestones and the remaining desktop acceptance
checks. Kitty is removed from the image; both Hypratomic and Wayblue's system
fallback use Foot. Existing personal configurations and recovery snapshots are
preserved: change any `kitty` launch commands in your own configuration to `foot`
when using the updated image.

## Project goal and layers

Hypratomic aims to be easy to reproduce, recover, rebuild, and set up quickly on
new hardware. Fedora Atomic provides the replaceable OS foundation; systematic,
version-controlled customizations provide the desktop and coding workflow.
Machine-specific settings, credentials, and personal files remain user-owned.
“Any system” means supported hardware, with documented prerequisites and graceful
fallbacks rather than contributor-specific monitor, GPU, or storage assumptions.

| Layer | Intended responsibility | Recovery boundary |
|---|---|---|
| OS image | Fedora Atomic, current Wayblue/Hyprland, shared packages | Redeploy a known image or roll back the OS |
| Desktop and editor | Managed defaults plus preserved personal overrides | Explicit activation and configuration restoration |
| Project environments | Recreate language tools from project definitions | Rebuild the environment without losing source files |
| AI integration | Optional local or remote providers and agent sessions | Reconnect providers without making editing depend on AI |
| User data | Self-hosted file access, synchronization, and separate backups | Recover files independently of the OS and configuration |

Following current upstream and reproducing a known setup are complementary:
record image digests, recipe revisions, tool versions, and project lockfiles for
validated releases, then update them deliberately. A moving `latest` tag alone
does not reproduce an earlier build. Archiving build inputs and testing recovery
on a fresh machine are planned work, not a claim of bit-for-bit reproducibility.

The desktop layer is implemented; the coding, AI, and user-data workflows below
are planned. Host-image work proceeds through the visual and shell phases before
project environments are added as a separate user-space layer. See
[PHASES.md](PHASES.md) for acceptance criteria and status.

Phase 3 starts with one restrained dark palette shared by Hyprland and Foot.
Run `hypratomic-theme` once as your user to install the Foot fragment; an existing
Foot configuration is preserved. Set a wallpaper explicitly with
`hypratomic-wallpaper /path/to/image [fill|fit|center|tile]`; it uses `swaybg`,
replaces only the wallpaper process it previously started, and never runs during
login. The Hyprland palette is loaded by the explicit Hypratomic profile and
remains reversible with `hypratomic-restore`.

## Build and test

```bash
python3 -m unittest discover -s tests -v
bluebuild validate recipes/recipe.yml
bluebuild build --build-driver docker recipes/recipe.yml
```

BlueBuild installs `files/system/` into the image root. The build checks helper
permissions, required desktop commands, and the configuration with the image's
`Hyprland --verify-config`. Unit tests use disposable homes inside `.cache/tests/`;
they exercise recovery without launching or modifying the current desktop.

The recipe follows `ghcr.io/wayblueorg/hyprland:latest`, so its Fedora and Hyprland
versions can change with upstream. Phase 2a uses upstream Hyprland Lua
configuration and APIs. We follow current upstream formats and keep changes to
Wayblue minimal, rather than pinning old versions to retain removed formats.
The build and activation validate the profile with the installed compositor.
Build validation runs as an unprivileged user in a temporary home.

Yazi is installed from the `lihaohong/yazi` COPR listed in
[Yazi's Fedora instructions](https://yazi-rs.github.io/docs/installation/#fedoracentos-stream-9rhel-9).
The recipe removes that repository after installation; image rebuilds supply updates.

## Activate the desktop

After booting an image containing these helpers, run as your normal user:

```bash
hypratomic-doctor
hypratomic-activate --dry-run
hypratomic-bootstrap
```

Bootstrap creates only missing files under `${XDG_CONFIG_HOME:-$HOME/.config}/hypratomic/`:

- `applications.lua`: application overrides, loaded before bindings.
- `monitors.lua`: machine-specific displays and scaling.
- `user.lua`: final local overrides and additional bindings.

Edit these `.lua` files. Defaults use automatic monitor discovery;
transfer any needed monitor layout and keyboard settings from your working
configuration before activation. Existing files and old Phase 1 staging folders
are preserved. General overrides are loaded last, but replacing a binding requires
an explicit `hl.unbind` first; the generated file includes an example.

```bash
hypratomic-activate
```

Activation checks dependencies, backs up the entire previous Hyprland directory
before creating overrides or changing the active configuration, validates a staged
configuration, then installs a small entry point loading image-owned modules from
`/usr/share/hypratomic/hypr/`. A backup or validation failure leaves the existing
configuration in place. Neither deployment nor login activates this profile.
Activation does not start services or explicitly reload Hyprland. A running
compositor may notice file changes; activate from a TTY after logging out for
the most predictable change.
Log in again to start the complete session.

Wayblue's launcher reads `~/.config/hypr/` explicitly, so that entry point stays
there even when `XDG_CONFIG_HOME` relocates your Hypratomic overrides. Activation
replaces both possible old entry points together, avoiding Lua/Hyprlang precedence
conflicts. It refuses a broken directory symlink or unexpected file at that path.

## Restore the previous Wayblue configuration

Run as the same user, including from a TTY (`Ctrl+Alt+F3`) if the desktop fails:

```bash
hypratomic-restore
```

Then log out and back in. Restoration needs no compositor or graphical session.
It reinstates the most recent activation cycle's saved directory or symlink, or
removes the managed entry point if no user configuration originally existed so
Wayblue's system default is used.
The outgoing configuration is archived rather than discarded.

Backups and the active recovery record live under
`${XDG_STATE_HOME:-$HOME/.local/state}/hypratomic/`. Repeated activation preserves
the original recovery point without creating another backup. After restoration,
the next activation saves a new recovery point; restore uses that latest cycle,
not an older backup or an outgoing archive. Interrupted swaps are rolled back on
the next helper invocation. A top-level symlink's target contents are also
snapshotted for manual recovery; normal restoration reinstates the original
symlink without overwriting its external target. Preserve this state directory until recovery is no longer needed.

Image updates refresh managed defaults without replacing user override files.
Previously activated Lua loaders keep working through a directory alias from
`/usr/share/hypratomic/defaults/hypr/lua/` to the current managed modules. This
preserves the existing recovery point and requires no automatic reactivation.
Port legacy `.conf` overrides to Lua manually; old files are preserved but not
loaded. Restoration preserves legacy backups exactly, even if the current
compositor no longer understands their syntax. OS rollback does not restore
files in `$HOME`; use configuration restoration separately.

The managed modules are `hyprland.lua`, `applications.lua`, `environment.lua`,
`monitors.lua`, `input.lua`, `autostart.lua`, `keybinds.lua`,
`look-and-feel.lua`, `workspaces.lua`, `windowrules.lua`, and `user.lua`.
Application overrides load before bindings; monitor settings stay user-owned;
`user.lua` loads last. No shared module names a contributor's monitor.

## Keyboard workflow

| Shortcut | Action |
|---|---|
| Super+Return | Foot |
| Super+Shift+Return or Super+Shift+B | Vivaldi Flatpak |
| Super+Shift+F | Yazi in Foot |
| Super+Space | Wofi application launcher |
| Super+K | Live Hyprland keybind list |
| Ctrl+Super+K | Tmux keybind list |
| Super+W | Close focused window |
| Super+F / Super+T / Super+J | Fullscreen / floating / toggle split |
| Super+arrows / Super+Shift+arrows | Focus / move window |
| Super+1–9,0 | Workspaces 1–10 |
| Super+Shift+1–9,0 | Move window without following |
| Super+S / Super+Shift+S | Show scratchpad / send window there |
| Super+mouse drag (left/right) | Move / resize window |
| Print | Select screenshot region and copy to clipboard |
| Super+V | Clipboard history picker |
| Super+Escape | Lock through Wayblue's swayidle integration |

Volume, brightness, and media keys are also bound. Clipboard history is stored by
`cliphist` in the user's cache; run `cliphist wipe` to clear it. Region/picker
cancellation leaves the clipboard unchanged.

The keybind viewer is provided by `hypratomic-keybinds`. The Hyprland view reads
the compositor's live binding registry, so user-added bindings appear after a
reload. The Tmux view reads the active Tmux key table; start Tmux first for the
complete configured list. Both views use Wofi and close without changing focus
or configuration.

The session helper retains Wayblue's D-Bus environment, keyring, wallet, polkit,
network applet, Waybar, and `/usr/share/swayidle/config` behavior. Existing matching
daemons are not started again. Wayblue's idle policy controls locking, display
power, and suspend. Notification/portal activation remains with the base image.
The recipe explicitly installs `swayidle`, `swaylock`, and `gnome-keyring` for
this helper; their presence is not assumed from the base image.

## Planned coding workflow

The image now includes Neovim and Tmux. Run `hypratomic-coding-bootstrap` once as
your user to install a preserved Tmux starting point under
`${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf`; it never replaces an existing
file. The intended launch sequence is Foot → Tmux → `nvim`.

The primary workflow is Hyprland → Foot → Tmux or Herder → Neovim/LazyVim,
with an Omarchy-inspired keyboard experience and Yazi for file navigation.
Tmux is the initial supported multiplexer; evaluate it alongside the
[Herder/herdr candidate](https://github.com/herdrdev/herdr) before selecting defaults.
Editor and multiplexer setup must be repeatable, preserve personal configuration,
and work without an AI account or a running local model.

### Keybinding ownership

| Layer | Binding policy |
|---|---|
| Hyprland | Super-based desktop/window/workspace actions; explicit media and system-key exceptions |
| Foot | Minimal terminal shortcuts that do not swallow multiplexer or editor commands |
| Tmux or Herder | A documented prefix and pane/session commands; audit direct shortcuts before enabling them |
| Neovim/LazyVim | Preserve modal keys, editor leader mappings, and Ctrl-based editing/navigation |
| AI plugin | A documented, unused editor leader subgroup after auditing LazyVim and plugin mappings |

Do not assign global desktop actions to bare editor keys, the editor leader, or
multiplexer prefixes. Keep the selected multiplexer close to upstream defaults;
choose and document any prefix change after checking editor and shell conflicts.
Test the complete chain in normal, insert, terminal, and copy modes, including
pane navigation, clipboard use, nested sessions, and SSH. Current compositor
bindings are predominantly Super-based; that alone is not proof that the full
future stack is conflict-free. The [Phase 2b keymap audit](docs/phase2b-keymap.md)
records ownership, the Tmux baseline, and the hardware verification procedure.
Publish one binding reference with each action's owner and an explicit
unbind/rebind procedure.

### Reproducible project environments

Provide a short, documented path from cloning a repository to opening its editor,
running tests, and rebuilding its environment. Start with Rust and
TypeScript/JavaScript templates. Evaluate [Toolbx](https://containertoolbx.org/)
and Distrobox/devcontainers for container-based toolchains, and optional
[Nix flakes/dev shells](https://nix.dev/concepts/flakes.html) for locked tool versions.
Choose one straightforward default; do not require several environment managers
for every project. Nix integration with Atomic storage and updates must be tested
before adoption.

Definitions belong with the project: base-image digests or flake locks, language
versions, dependency lockfiles, build/test commands, and any service dependencies.
Compilers, LSP servers, formatters, debuggers, and AI-run commands must use the same
project environment, with documented host/container paths and UID ownership.
Avoid installing each project's language stack into the host image. Development
environments isolate dependencies; shared-home containers and dev shells are not
assumed to be security sandboxes. Verify deletion/recreation without losing source
files, and document first-use downloads and offline limits.

### AI inside Neovim/LazyVim

Aim for a Zed-like threads/agents experience inside the editor: multiple
project-scoped conversations, explicit file/selection context, resumable history,
agent progress and cancellation, and reviewable edits with accept/reject controls.
Support both local Ollama and remote providers through one configurable workflow;
provider choice, credentials, model downloads, and GPU settings stay user-owned.
Local inference should have a documented CPU or remote fallback where practical.

[CodeCompanion](https://github.com/olimorris/codecompanion.nvim) is an initial
candidate: its upstream documentation lists Ollama and remote providers, multiple
chats, code review, and Agent Client Protocol integration. Evaluate it against the
workflow above before selecting it; these capabilities do not establish full Zed
parity, persistent history behavior, or equivalent tool use across models.

Keep provider setup optional and reversible. Store secrets outside image layers
and tracked files; make remote context transmission explicit. Agent shell commands
must use the project environment, and changes must remain reviewable and undoable.
The editor must remain usable when a provider is unavailable.

## Planned user-data and recovery layer

Provide a self-hosted, OneDrive-like experience for personal files: background
synchronization while online, files-on-demand/virtual files, explicit offline
pinning, bounded local caches, visible sync/conflict status, and easy reconnection
on a replacement machine. This layer is separate from the image, desktop
configuration, project toolchains, and optional AI services.

Evaluate Seafile/SeaDrive and Nextcloud before selecting a service.
[SeaDrive documents a Linux virtual-drive client](https://help.seafile.com/drive_client/drive_client_for_linux/),
including AppImage/FUSE requirements; validate those requirements on Fedora Atomic
and file access through Yazi, Neovim, and CLI tools. Require an actual Linux
files-on-demand test for Nextcloud rather than assuming feature parity with its
Windows/macOS clients. Compare offline writes, conflicts, permissions/symlinks,
large files, startup/reconnect behavior, server maintenance, and licensing.

Synchronization is not sufficient backup: deletions and corruption can propagate.
Pair it with independently retained, versioned backups and documented retention,
encryption/key recovery, and restore tests. Back up the self-hosted server's data,
metadata/database, and configuration as required by the chosen service. A backup
of a placeholder-only client directory is not a backup of the remote file contents.
Define recovery-point and recovery-time targets before choosing an implementation;
“real-time” sync does not guarantee zero data loss during outages.

Keep active Git worktrees on local storage by default until virtual-drive locking,
file watching, and offline behavior have been tested. Back up source files and
uncommitted work deliberately; exclude rebuildable caches, `node_modules`, build
outputs, downloaded models, and container layers by default. Keep the configuration
recovery records under `~/.local/state/hypratomic/` (or `XDG_STATE_HOME`) in the
recovery plan as well. Document recovery after both client-disk loss and server
loss, including credentials and encryption keys retrieved from a separate source.

## Image installation and signing

The recipe's image name is `hypratomic`. For a newly built image published from
this repository, use `ghcr.io/isaaccrum/hypratomic:latest`; confirm the actual image
name in the successful CI run before rebasing. Older deployments may still use
`fedora-hypr` and should not infer a rename from these docs alone.

For an initial installation, replace `OWNER` with the publishing account:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/OWNER/hypratomic:latest
systemctl reboot
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/OWNER/hypratomic:latest
systemctl reboot
```

For subsequent updates use the signed image. The existing OS recovery procedure is
`sudo rpm-ostree rollback` followed by a reboot. These commands change the host;
repository development and tests do not run them.

CI uses `SIGNING_SECRET` and the workflow's registry token. Never commit private
signing keys. Verify the published image with:

```bash
cosign verify --key cosign.pub ghcr.io/OWNER/hypratomic:latest
```

## Configuration references

- [Wayblue's Hyprland defaults](https://github.com/wayblueorg/wayblue/tree/live/files/system/hyprland)
- [Hyprland configuration](https://github.com/hyprwm/Hyprland/tree/main/src/config)
- [BlueBuild file installation](https://blue-build.org/reference/modules/files/)

See [docs/phase2-validation.md](docs/phase2-validation.md) for the hardware checklist.
