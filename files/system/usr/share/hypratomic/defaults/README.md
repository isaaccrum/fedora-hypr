# Hypratomic managed defaults

These files are owned by the OS image. The upstream Hyprland Lua modules
live in `/usr/share/hypratomic/hypr/`. `hypratomic-bootstrap` creates missing user
overrides without copying or activating the managed desktop. `hypratomic-activate`
backs up the working Hyprland configuration and installs an explicit loader.
`hypratomic-restore` returns to the previous configuration without requiring a GUI.

Machine-specific monitors, application overrides, and personal settings live under
`${XDG_CONFIG_HOME:-$HOME/.config}/hypratomic/`. Never overwrite them during an image
update. Quickshell remains a placeholder and is not started by these defaults.
