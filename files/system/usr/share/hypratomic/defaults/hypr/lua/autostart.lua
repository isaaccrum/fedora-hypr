-- Preserve Wayblue's services; helper avoids duplicate daemon startup.
hl.on("hyprland.start", function()
    hl.exec_cmd("hypratomic-session")
end)
