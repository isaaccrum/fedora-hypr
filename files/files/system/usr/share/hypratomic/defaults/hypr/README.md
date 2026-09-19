# Hyprland configuration — Phase 2 target

The active Hyprland configuration is intentionally not replaced in Phase 1.

Planned split:

- `hyprland.conf` — sources the files below
- `monitors.conf` — machine-specific; never overwritten automatically
- `input.conf`
- `environment.conf`
- `autostart.conf`
- `keybinds.conf`
- `look-and-feel.conf`
- `windowrules.conf`
- `user.conf` — final local override

The design rule is that machine-specific monitor settings and user overrides
remain mutable while shared defaults live in the image/repository.
