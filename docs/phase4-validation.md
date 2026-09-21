# Phase 4 Quickshell validation

## Current preview

Run `hypratomic-quickshell --check` to verify the installed preview, then run
`hypratomic-quickshell` from a Foot terminal to start the bar manually. It copies
the preview to `~/.config/quickshell/hypratomic/shell.qml` only when that file is
absent. Stop it with `Ctrl-C`; Waybar remains active throughout this preview.

Quickshell remains an explicit opt-in during Phase 4. Waybar and the existing
Wayblue session services remain the recovery shell until every required surface
has been tested.

## Evaluation order

1. Start Quickshell manually from a terminal in a disposable user configuration.
2. Test the bar without disabling Waybar.
3. Add and test the launcher, notifications, OSD, and power/session controls one
   surface at a time.
4. Test network, Bluetooth, volume, brightness, lock, suspend, and logout actions.
5. Confirm Hyprland, Foot, Tmux, Neovim, screenshots, wallpapers, and clipboard
   behavior remain unchanged.
6. Test a broken or missing Quickshell configuration and recover by returning to
   Waybar from a TTY.
7. Only after a complete successful session test may the normal session start
   Quickshell; Waybar must remain available through an explicit fallback path.

## Safety requirements

- Deployment and login do not start Quickshell during evaluation.
- A Quickshell configuration is user-owned and must be backed up before changes.
- Quickshell must not start services already owned by Wayblue, including keyring,
  D-Bus, idle/lock, notification, portal, or network services.
- The shell must use the Phase 3 palette and preserve the `Super` key ownership
  and the Foot → Tmux → Neovim workflow.
- A failed shell activation must leave the previous shell recoverable from a TTY.
