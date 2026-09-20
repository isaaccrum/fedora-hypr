# Repository Guidelines

## Agent Permissions

Codex may freely read, create, and modify files inside the current repository directory and run ordinary development commands, such as searches, Git inspection, formatting, linting, tests, and local builds, without additional approval.

Obtain user approval before actions outside the repository or potentially destructive/system-level commands, including deleting user data, discarding Git changes, installing host packages, changing services, activating desktop configuration, rebasing or rolling back the OS, and rebooting. Judge commands by their effects, not their working directory; following a symlink outside the repository counts as outside access. Existing explicit authorization covers its stated scope. Sandbox restrictions still apply.

## Project Structure & Module Organization

Hypratomic builds a Fedora Atomic desktop image on Wayblue Hyprland using BlueBuild.

- `recipes/recipe.yml` defines the base image, packages, Flatpaks, file installation, and signing.
- `files/system/usr/` contains installed helpers, the recovery engine, and managed defaults. The recipe installs `files/system/` at the image root.
- `files/scripts/` contains build-script examples; `modules/` is reserved for custom modules.
- `.github/workflows/build.yml` handles image builds. Keep milestone status and implementation progress in `PHASES.md`, not this guide.

## Build, Test, and Development Commands

Run from the repository root with BlueBuild installed:

```bash
bluebuild generate ./recipes/recipe.yml -o Containerfile
bluebuild build ./recipes/recipe.yml
```

These generate a Containerfile and build the image locally, respectively.

Check Bash syntax without executing helpers:

```bash
bash -n files/scripts/example.sh
bash -n files/system/usr/bin/hypratomic-bootstrap
bash -n files/system/usr/bin/hypratomic-doctor
python3 -m unittest discover -s tests -v
```

Run `hypratomic-doctor` on a deployed test image.

## Coding Style & Naming Conventions

Use two-space YAML and four-space Bash indentation. Bash scripts require `#!/usr/bin/env bash`, `set -euo pipefail`, and quoted variable expansions. Name helpers `hypratomic-*`. Keep the recipe's schema declaration. No formatter or linter is configured.

## Testing Guidelines

Standard-library tests in `tests/` exercise recovery in isolated homes. No coverage threshold is set. Image builds validate configuration using the installed compositor. Verify desktop operation, `hypratomic-doctor`, and restoration on test hardware; follow `docs/phase2-validation.md`.

## Commit & Pull Request Guidelines

Use concise, action-oriented subjects; history also uses `chore(deps):` and `chore(automatic):`. PRs should explain changes and validation, link relevant issues, and include screenshots for visible desktop changes.

## Architectural Rules

- Track current upstream Wayblue and Hyprland versions and keep divergence from their defaults, APIs, and session integration minimal. Use the configuration format supported by current upstream Hyprland (currently Lua); migrate away from formats upstream removes. Do not pin or downgrade the base image or compositor, or add compatibility layers, merely to retain an obsolete configuration format.
- Keep managed defaults under `/usr/share/hypratomic/` and user settings under `${XDG_CONFIG_HOME:-$HOME/.config}/hypratomic/`. Image updates and bootstrap must preserve existing user files.
- Split Hyprland configuration into focused modules with explicit source ordering. Load application overrides before bindings and general user overrides last; document unbind/rebind behavior.
- Keep monitor configuration machine-specific and user-owned. Never hardcode contributor hardware into shared defaults.
- Use Foot as the default terminal and Yazi as the default file manager, launched inside Foot. Do not depend on Kitty for desktop operation.
- Make desktop activation explicit and reversible. Back up the working configuration before replacement, preserve directory/symlink/absent state, and retain the original recovery point across repeated activation.
- Store recovery state under `${XDG_STATE_HOME:-$HOME/.local/state}/hypratomic/`. Restoration must work from a TTY without a running compositor; failed activation must recover the previous configuration.
- Preserve Wayblue session integration and avoid duplicate service startup. Keep Waybar available as a known-good fallback. Installing an alternative shell must not automatically activate it.

## Signing

Never commit private signing keys; CI currently reads `SIGNING_SECRET`, and `cosign.pub` is public.
