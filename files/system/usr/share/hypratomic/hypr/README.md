# Modular Hyprland configuration

This profile uses upstream Hyprland Lua syntax and APIs. The activation helper
writes a loader defining `hypratomic.defaults` (this directory) and `hypratomic.user`
(the user override directory), then sources `hyprland.lua`.

Load order: application defaults, user application overrides, environment, input,
look and feel, workspaces, window rules, monitors, bindings, autostart, and final
user overrides. `monitors.lua` and `user.lua` source user-owned files created
from `user/` only when absent. Application overrides precede bindings; replacing
a binding in the final user file requires `hl.unbind` before `hl.bind`.

Foot is the terminal; Yazi runs inside Foot. `hypratomic-session` starts the
managed Quickshell and Walker provider service by default, while preserving
Wayblue's other session services. Use `hypratomic-session --waybar` from a
graphical recovery shell to use Waybar as the fallback. Nothing activates this profile
during deployment; run `hypratomic-activate` explicitly. Use
`hypratomic-restore` from a TTY to restore the saved configuration without a
compositor.

The old `defaults/hypr/lua` path aliases this directory so existing Lua loaders
continue working across image updates without replacing their recovery records.
