"""Exercise picker cancellation and clipboard transfer without a Wayland session."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
BIN = ROOT / 'files/system/usr/bin'


class DesktopHelperTests(unittest.TestCase):
    def setUp(self):
        cache = ROOT / '.cache/tests'
        cache.mkdir(parents=True, exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(dir=cache)
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.clipboard = self.root / 'clipboard'
        self.clipboard.write_bytes(b'previous clipboard')
        self.env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ['PATH'],
                        XDG_RUNTIME_DIR=str(self.root), CLIPBOARD=str(self.clipboard))
        self.stub('wl-copy', '''from pathlib import Path
import os, sys
Path(os.environ['CLIPBOARD']).write_bytes(sys.stdin.buffer.read())
''')

    def stub(self, name, source):
        path = self.bin / name
        path.write_text(f'#!{sys.executable}\n' + source)
        path.chmod(0o755)

    def run_helper(self, name):
        return subprocess.run(['bash', str(BIN / name)], env=self.env,
                              capture_output=True, check=False)

    def test_screenshot_cancellation_keeps_clipboard(self):
        self.stub('slurp', 'import sys; sys.exit(1)\n')
        result = self.run_helper('hypratomic-screenshot')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.clipboard.read_bytes(), b'previous clipboard')

    def test_failed_screenshot_keeps_clipboard_and_removes_temporary_file(self):
        self.stub('slurp', 'print("1,2 30x40")\n')
        self.stub('grim', 'import sys; sys.exit(1)\n')
        result = self.run_helper('hypratomic-screenshot')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.clipboard.read_bytes(), b'previous clipboard')
        self.assertEqual(list(self.root.glob('hypratomic-screenshot.*')), [])

    def test_screenshot_copies_binary_data_and_removes_temporary_file(self):
        self.stub('slurp', 'print("1,2 30x40")\n')
        self.stub('grim', '''from pathlib import Path
import sys
assert sys.argv[1:3] == ['-g', '1,2 30x40']
Path(sys.argv[3]).write_bytes(b'PNG\\x00\\xff')
''')
        result = self.run_helper('hypratomic-screenshot')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.clipboard.read_bytes(), b'PNG\x00\xff')
        self.assertEqual(list(self.root.glob('hypratomic-screenshot.*')), [])

    def test_clipboard_picker_cancellation_keeps_clipboard(self):
        self.stub('cliphist', 'print("1\\ttext")\n')
        self.stub('walker', 'import sys; sys.stdin.read(); sys.exit(1)\n')
        result = self.run_helper('hypratomic-clipboard')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.clipboard.read_bytes(), b'previous clipboard')

    def test_clipboard_picker_decodes_selected_binary_entry(self):
        self.stub('cliphist', '''import sys
if sys.argv[1] == 'list':
    print('1\\timage')
else:
    assert sys.stdin.read() == '1\\timage\\n'
    sys.stdout.buffer.write(b'image\\x00\\xff')
''')
        self.stub('walker', 'import sys; sys.stdout.write(sys.stdin.read())\n')
        result = self.run_helper('hypratomic-clipboard')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.clipboard.read_bytes(), b'image\x00\xff')


if __name__ == '__main__':
    unittest.main()
