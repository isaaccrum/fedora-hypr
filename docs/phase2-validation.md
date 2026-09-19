# Phase 2 validation

## Repository checks

```bash
python3 -m unittest discover -s tests -v
for script in files/system/usr/bin/hypratomic-* files/scripts/*.sh; do
    bash -n "$script"
done
bluebuild generate ./recipes/recipe.yml -o Containerfile
bluebuild build ./recipes/recipe.yml
```

Transaction tests mock the compositor validation call; they verify filesystem
behavior, not Hyprland syntax. The recipe's `validate-hypratomic.sh` checks the
installed payload, dependencies, and selected configuration with the real image's
compositor. Both checks are necessary. No test switches the host desktop.

## Hardware acceptance

Use a test deployment, preserving its working Wayblue configuration and the
already-tested OS rollback path. Record `Hyprland --version` and the image digest.

- [ ] Build CI passes, including image-side configuration validation.
- [ ] `hypratomic-doctor` finds required commands.
- [ ] `hypratomic-activate --dry-run` reports the expected paths and format.
- [ ] Bootstrap preserves existing overrides on a second invocation.
- [ ] Configure the user-owned monitor file for this machine, if needed.
- [ ] Log out, activate from a TTY as the normal user, and log in again.
- [ ] Foot, launcher, Thunar, browser, window movement, and workspaces work.
- [ ] Screenshots reach the clipboard; clipboard history works for text/images.
- [ ] Waybar appears once; network, notifications, audio, and screen sharing work.
- [ ] Manual lock, idle lock, and suspend/resume work; a session remains locked
      on resume. Confirm behavior from the base's swayidle policy.
- [ ] Quickshell is not running; no binding depends on Kitty.
- [ ] `hyprctl configerrors` reports no errors.
- [ ] Repeat activation and confirm the original recovery record is unchanged.
- [ ] Run `hypratomic-restore` from a TTY and log in to the previous Wayblue setup.
- [ ] Confirm monitor and user override files survived restoration.
- [ ] Activate again and verify two clean logins/boots.

If moving between Hyprlang and Lua images, restore the previous profile, bootstrap
the new format, and port personal settings explicitly before reactivation. Review
the selected `applications`, `monitors`, and `user` files; the other format's files
are preserved but are not loaded. OS rollback does not rewind user configuration.
