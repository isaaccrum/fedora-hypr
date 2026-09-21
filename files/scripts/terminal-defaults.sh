#!/usr/bin/env bash
set -euo pipefail

# Keep Wayblue's fallback usable without activating the Hypratomic profile.
# Only image-owned defaults are changed; saved user configurations stay intact.
python3 - <<'PY'
from pathlib import Path

path = Path('/usr/share/hyprland/hyprland.lua')
text = path.read_text()
old = 'local terminal = "kitty"'
new = 'local terminal = "foot"'
if old not in text and new not in text:
    raise SystemExit('Wayblue terminal declaration changed; review its fallback configuration')
path.write_text(text.replace(old, new))
PY

command -v foot
if command -v kitty || rpm -qa --qf '%{NAME}\n' | grep -E '^kitty($|-)'; then
    printf 'Kitty remains in the image after removal\n' >&2
    exit 1
fi
