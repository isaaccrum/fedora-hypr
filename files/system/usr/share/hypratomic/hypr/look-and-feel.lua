-- Initial Hypratomic palette and restrained visual defaults.
local palette = hypratomic.palette
hl.config({
    general = {
        layout = "dwindle",
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        resize_on_border = true,
        allow_tearing = false,
        col = {
            active_border = palette.accent,
            inactive_border = palette.border,
        },
    },
    decoration = {
        rounding = 8,
        active_opacity = 0.97,
        inactive_opacity = 0.94,
    },
    misc = {
        background_color = palette.background,
        font_family = "monospace",
    },
    animations = { enabled = false },
})
