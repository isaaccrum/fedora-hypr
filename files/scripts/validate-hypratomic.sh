#!/usr/bin/env bash
set -euo pipefail

# Run inside the image: verify the payload and configuration against its Hyprland.
for name in bootstrap activate restore doctor session clipboard screenshot; do
    test -x "/usr/bin/hypratomic-$name"
done
test -f /usr/libexec/hypratomic/config.py
for module in hyprland environment monitors input autostart keybinds look-and-feel windowrules user; do
    test -r "/usr/share/hypratomic/hypr/$module.lua"
done

# Package names can differ from the executable name. Diagnostics must not
# prevent the actual configuration check from running.
if compositor="$(command -v Hyprland || command -v hyprland)"; then
    printf 'Image compositor: %s\n' "$compositor"
    if ! rpm -qf -- "$(readlink -f -- "$compositor")"; then
        printf 'Could not determine the compositor RPM; continuing validation.\n'
    fi
fi

validation_home="$(mktemp -d)"
trap 'rm -rf -- "$validation_home"' EXIT
HOME="$validation_home" XDG_CONFIG_HOME="$validation_home/.config" \
    XDG_STATE_HOME="$validation_home/.local/state" PYTHONDONTWRITEBYTECODE=1 python3 -u - <<'PY'
import importlib.util
import os
from pathlib import Path
import pwd
import shutil
import subprocess

home = Path(os.environ['HOME'])
if os.geteuid() == 0:
    # The image's parse-only validator can crash after binding /.socket2.sock
    # as root. Validate with ordinary user permissions in our isolated home.
    account = pwd.getpwnam('nobody')
    os.chown(home, account.pw_uid, account.pw_gid)
    os.setgroups([])
    os.setgid(account.pw_gid)
    os.setuid(account.pw_uid)

spec = importlib.util.spec_from_file_location('hypratomic_config', '/usr/libexec/hypratomic/config.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
config = module.Configuration(home, home / '.config', home / '.local/state', Path('/usr'))
config.preflight()
config.bootstrap()
try:
    config.verify(config.loader(home / 'validation'))
except subprocess.CalledProcessError as error:
    print(f'Hypratomic validation failed (return code {error.returncode}).', flush=True)
    # Parse-only Hyprland can redirect its output here before crashing.
    log = Path('/hyprland.log')
    if log.is_file():
        print('--- Hyprland validation log (last 64 KiB) ---')
        with log.open('rb') as stream:
            stream.seek(max(0, log.stat().st_size - 65536))
            print(stream.read().decode('utf-8', errors='replace'), flush=True)
    # Compare against the image's own defaults without accepting a failed check.
    sample = Path('/usr/share/hyprland') / f'hyprland.{config.format}'
    if sample.is_file():
        probe = home / 'sample-validation'
        probe.mkdir()
        shutil.copytree(sample.parent, probe, dirs_exist_ok=True)
        print(f'Checking shipped sample: {sample}', flush=True)
        try:
            config.verify(probe / sample.name)
        except subprocess.CalledProcessError as sample_error:
            print(f'Shipped sample also failed (return code {sample_error.returncode}).', flush=True)
        else:
            print('Shipped sample passed on the subsequent run; this does not rule out a first-run compositor bug.', flush=True)
    raise
print(f'Validated Hypratomic {config.format} configuration against the image compositor')

# Exercise the installed entry points only in the disposable build home.
# The EXIT trap removes this home; no deployed user's desktop is activated.
config.active.mkdir(parents=True)
original = config.active / 'hyprland.conf'
original.write_text('# Build validation recovery point\n')
for action in ('activate', 'restore'):
    subprocess.run([f'/usr/bin/hypratomic-{action}'], check=True)
if original.read_text() != '# Build validation recovery point\n' or config.record.exists():
    raise RuntimeError('Activation/restoration did not preserve the build recovery point')
print('Validated installed activation and restoration helpers in an isolated home')
PY
