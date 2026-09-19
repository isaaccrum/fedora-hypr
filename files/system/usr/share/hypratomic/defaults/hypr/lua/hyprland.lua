-- Shared defaults are image-owned; personal files are sourced explicitly.
local function managed(name) dofile(hypratomic.defaults .. "/" .. name .. ".lua") end
local function user(name) dofile(hypratomic.user .. "/" .. name .. ".lua") end
managed("applications")
user("applications")
managed("environment")
managed("input")
managed("look-and-feel")
managed("workspaces")
managed("windowrules")
user("monitors")
managed("keybinds")
managed("autostart")
user("user")
