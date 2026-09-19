# Modular Hyprland defaults

`conf/` supports Hyprlang bases; `lua/` supports Wayblue's Lua bases. Bootstrap and
activation select Lua when `/usr/share/hyprland/hyprland.lua` exists; otherwise they
select Hyprlang. Image builds and activation validate with the installed Hyprland.

The entry point loads application defaults, user application overrides, environment,
input, layout, workspaces, window rules, user monitor configuration, keybindings,
autostart, and final user overrides, in that order. Managed modules stay in the
image. User files are created only when absent, using templates in `user/`.

Foot is the terminal. Autostart calls `hypratomic-session`, which preserves Wayblue
services and Waybar. No Quickshell activation or replacement session is installed.
