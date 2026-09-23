# Phase 4 Quickshell validation

## Default shell

Quickshell starts automatically from `hypratomic-session`. Run
`hypratomic-quickshell --check` to verify the installed configuration. The
helper copies the managed shell to `~/.config/quickshell/hypratomic/shell.qml`
only when that file is absent, preserving user changes.

The session helper owns only the long-lived processes it starts. Ownership
records live under `$XDG_RUNTIME_DIR/hypratomic-session`; one-shot D-Bus, keyring,
and wallet setup is reported separately. Re-running the helper reconciles the
requested shell without stopping unrelated user processes. Inspect the plan
without starting anything with `hypratomic-session --plan`.

Waybar remains available as an explicit fallback with
`hypratomic-session --waybar` from a recovery shell inside the graphical user
session. Use a TTY to restore the Hyprland configuration, then log in and invoke
the fallback session.

The fallback stops only a Hypratomic-owned Quickshell process. It keeps Elephant
running so Walker remains available. An unowned conflicting shell is reported
and prevents a second visible shell from starting.

The notification server is separately opt-in during testing:

```bash
hypratomic-quickshell --notifications
```

It registers Quickshell as the notification server and displays one themed toast
for six seconds. Only one desktop notification server may own the D-Bus
notification name, so stop any existing notification daemon before testing this
mode. Stop it with `Ctrl-C` to return to the existing daemon.

The bar's `Power` button launches `hypratomic-power-menu`. It offers lock,
suspend, logout, reboot, and poweroff actions through Walker; no action occurs
until one is selected. Check it with `hypratomic-power-menu --check`.

## Evaluation order

1. Start a disposable session with the default Quickshell shell.
2. Test the bar and Walker launcher.
3. Add and test the launcher, notifications, OSD, and power/session controls one
   surface at a time.
4. Test network, Bluetooth, volume, brightness, lock, suspend, and logout actions.
5. Confirm Hyprland, Foot, Tmux, Neovim, screenshots, wallpapers, and clipboard
   behavior remain unchanged.
6. Test a broken or missing Quickshell configuration and recover by returning to
   Waybar from a TTY.
7. Keep Waybar available through the explicit fallback path.

## Safety requirements

- Image deployment does not start Quickshell; login starts it through the managed
  session helper.
- A Quickshell configuration is user-owned and must be backed up before changes.
- Quickshell must not start services already owned by Wayblue, including keyring,
  D-Bus, idle/lock, notification, portal, or network services.
- The shell must use the Phase 3 palette and preserve the `Super` key ownership
  and the Foot → Tmux → Neovim workflow.
- A failed shell activation must leave the previous shell recoverable from a TTY.
