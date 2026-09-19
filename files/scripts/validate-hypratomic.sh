#!/usr/bin/env bash
set -euo pipefail

# Run inside the image: verify the payload and configuration against its Hyprland.
for name in bootstrap activate restore doctor session clipboard screenshot; do
    test -x "/usr/bin/hypratomic-$name"
done
test -f /usr/libexec/hypratomic/config.py

validation_home="$(mktemp -d)"
trap 'rm -rf -- "$validation_home"' EXIT
HOME="$validation_home" XDG_CONFIG_HOME="$validation_home/.config" \
    XDG_STATE_HOME="$validation_home/.local/state" PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
import importlib.util
import os
from pathlib import Path

spec = importlib.util.spec_from_file_location('hypratomic_config', '/usr/libexec/hypratomic/config.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
home = Path(os.environ['HOME'])
config = module.Configuration(home, home / '.config', home / '.local/state', Path('/usr'))
config.preflight()
config.bootstrap()
config.verify(config.loader(home / 'validation'))
print(f'Validated Hypratomic {config.format} configuration against the image compositor')
PY
