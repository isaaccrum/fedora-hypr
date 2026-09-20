# Hypratomic

A BlueBuild Fedora Atomic image based on Wayblue Hyprland, with an
Omarchy-inspired keyboard workflow and a recoverable desktop configuration.
Foot is the standard terminal; Yazi is the default file manager. Waybar remains
the active bar; Quickshell is installed for future work but is not started.

Phase 1 builds, boots, rebases, and OS rollback have been tested on hardware.
See [PHASES.md](PHASES.md) for milestones and the remaining desktop acceptance
checks. Kitty native-Wayland troubleshooting is outside this project's scope.

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

The session helper retains Wayblue's D-Bus environment, keyring, wallet, polkit,
network applet, Waybar, and `/usr/share/swayidle/config` behavior. Existing matching
daemons are not started again. Wayblue's idle policy controls locking, display
power, and suspend. Notification/portal activation remains with the base image.
The recipe explicitly installs `swayidle`, `swaylock`, and `gnome-keyring` for
this helper; their presence is not assumed from the base image.

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
