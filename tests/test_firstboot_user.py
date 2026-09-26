import os
import pathlib
import subprocess
import tempfile
import unittest


SCRIPT = pathlib.Path(__file__).parents[1] / "files/system/usr/bin/hypratomic-firstboot-user"


class FirstBootUserTests(unittest.TestCase):
    def run_setup(self, answers: str):
        root = pathlib.Path(tempfile.mkdtemp())
        etc = root / "etc"
        etc.mkdir()
        passwd = etc / "passwd"
        group = etc / "group"
        passwd.write_text("root:x:0:0:root:/root:/bin/bash\n")
        group.write_text("root:x:0:\nwheel:x:10:\n")
        state = root / "state"
        bin_dir = root / "bin"
        bin_dir.mkdir()
        useradd = bin_dir / "useradd"
        useradd.write_text(
            "#!/usr/bin/env bash\n"
            "name=${@: -1}\n"
            "echo \"$name:x:1000:1000::/home/$name:/bin/bash\" >> \"$PASSWD_FILE\"\n"
            "sed -i \"s/^wheel:x:10:/wheel:x:10:$name,/\" \"$GROUP_FILE\"\n"
        )
        useradd.chmod(0o755)
        chpasswd = bin_dir / "chpasswd"
        chpasswd.write_text("#!/usr/bin/env bash\ncat > \"$PASSWORD_FILE\"\n")
        chpasswd.chmod(0o755)
        password_file = root / "password"
        env = os.environ | {
            "HYPRATOMIC_PASSWD_FILE": str(passwd),
            "HYPRATOMIC_GROUP_FILE": str(group),
            "HYPRATOMIC_STATE_DIR": str(state),
            "HYPRATOMIC_INPUT": str(root / "input"),
            "HYPRATOMIC_OUTPUT": str(root / "output"),
            "HYPRATOMIC_USERADD": str(useradd),
            "HYPRATOMIC_CHPASS": str(chpasswd),
            "PASSWORD_FILE": str(password_file),
            "PASSWD_FILE": str(passwd),
            "GROUP_FILE": str(group),
            "HYPRATOMIC_ALLOW_NONROOT_TEST": "1",
        }
        (root / "input").write_text(answers)
        result = subprocess.run([str(SCRIPT)], env=env, text=True, capture_output=True)
        return result, passwd, group, state, password_file

    def test_creates_wheel_user_on_unconfigured_system(self):
        result, passwd, group, state, password_file = self.run_setup("alice\nAlice Example\nsecret\nsecret\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("alice", passwd.read_text())
        self.assertIn("wheel:x:10:alice", group.read_text())
        self.assertEqual(password_file.read_text(), "alice:secret\n")
        self.assertTrue((state / "firstboot-user.done").exists())

    def test_rejects_mismatched_password(self):
        result, passwd, _, state, _ = self.run_setup("alice\n\none\ntwo\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("alice:x:1000", passwd.read_text())
        self.assertFalse((state / "firstboot-user.done").exists())


if __name__ == "__main__":
    unittest.main()
