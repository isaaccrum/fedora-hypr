"""Exercise session planning and conflict handling without a desktop session."""

from pathlib import Path
import os
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SESSION = ROOT / 'files/system/usr/bin/hypratomic-session'


class SessionTests(unittest.TestCase):
    def test_plan_is_side_effect_free(self):
        with tempfile.TemporaryDirectory() as runtime:
            result = subprocess.run(
                ['bash', str(SESSION), '--plan'],
                env=dict(os.environ, XDG_RUNTIME_DIR=runtime),
                capture_output=True, text=True, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('Shell: owned quickshell process', result.stdout)
            self.assertFalse((Path(runtime) / 'hypratomic-session').exists())

    def test_unowned_conflicting_shell_blocks_start(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            runtime = root / 'runtime'
            runtime.mkdir()
            pgrep = root / 'pgrep'
            pgrep.write_text(
                '#!/usr/bin/env bash\n'
                '[[ "$*" == *" -x waybar"* ]] && exit 0\n'
                'exit 1\n'
            )
            pgrep.chmod(0o755)
            env = dict(
                os.environ,
                XDG_RUNTIME_DIR=str(runtime),
                HYPRATOMIC_PGREP=str(pgrep),
                HYPRATOMIC_DBUS_UPDATE='/usr/bin/true',
                HYPRATOMIC_KEYRING='/usr/bin/true',
                HYPRATOMIC_KWALLET='/usr/bin/true',
                HYPRATOMIC_POLKIT='/usr/bin/true',
                HYPRATOMIC_SWAYIDLE_CONFIG='/dev/null',
            )
            result = subprocess.run(
                ['bash', str(SESSION)], env=env,
                capture_output=True, text=True, check=False,
            )
            self.assertEqual(result.returncode, 1)
            self.assertIn('unowned conflicting shell', result.stderr)
            self.assertFalse((runtime / 'hypratomic-session/quickshell.pid').exists())


if __name__ == '__main__':
    unittest.main()
