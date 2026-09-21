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

- Optimize for a reproducible, recoverable, rebuildable setup that can be provisioned quickly on supported hardware. Keep OS image, managed configuration, project environments, AI integration, and user data as separate layers with explicit setup and recovery procedures. Record validated image digests, source revisions, and lockfiles while continuing deliberate upstream updates; do not equate a moving `latest` tag with reproducibility.
- Track current upstream Wayblue and Hyprland versions and keep divergence from their defaults, APIs, and session integration minimal. Use the configuration format supported by current upstream Hyprland (currently Lua); migrate away from formats upstream removes. Do not pin or downgrade the base image or compositor, or add compatibility layers, merely to retain an obsolete configuration format.
- Keep managed defaults under `/usr/share/hypratomic/` and user settings under `${XDG_CONFIG_HOME:-$HOME/.config}/hypratomic/`. Image updates and bootstrap must preserve existing user files.
- Split Hyprland configuration into focused modules with explicit source ordering. Load application overrides before bindings and general user overrides last; document unbind/rebind behavior.
- Keep monitor configuration machine-specific and user-owned. Never hardcode contributor hardware into shared defaults.
- Use Foot as the default terminal and Yazi as the default file manager, launched inside Foot. Remove Kitty packages from the image and keep Wayblue's system fallback using Foot. Preserve existing user configurations and recovery snapshots rather than rewriting their terminal bindings.
- Make desktop activation explicit and reversible. Back up the working configuration before replacement, preserve directory/symlink/absent state, and retain the original recovery point across repeated activation.
- Store recovery state under `${XDG_STATE_HOME:-$HOME/.local/state}/hypratomic/`. Restoration must work from a TTY without a running compositor; failed activation must recover the previous configuration.
- Preserve Wayblue session integration and avoid duplicate service startup. Keep Waybar available as a known-good fallback. Installing an alternative shell must not automatically activate it.
- Design the coding workflow around Foot, Neovim/LazyVim, and Tmux or Herder. Reserve Super-based bindings for Hyprland; preserve editor modal/leader keys and multiplexer prefixes. Audit Foot, shell, multiplexer, editor, and AI-plugin mappings together, document ownership and exceptions, and test the complete input path before claiming bindings are conflict-free.
- Keep project language stacks out of the host image where practical. Evaluate Toolbx/Distrobox/devcontainers and optional Nix flakes using declarative Rust and TypeScript/JavaScript examples. Keep language tools, LSPs, tests, and agent commands in the same project environment; document filesystem access and do not assume dependency isolation provides a security sandbox.
- Make local Ollama and remote AI integrations optional and provider-configurable. Target project-scoped threads/agents inside Neovim/LazyVim with resumable history and reviewable, undoable edits. Preserve normal editing without AI; keep credentials, model caches, hardware settings, and conversation data user-owned and outside tracked files/image layers. Make remote transmission of project context explicit.
- Keep user-file synchronization and backup independent of OS/configuration rollback. Evaluate self-hosted Seafile/SeaDrive or Nextcloud for Linux files-on-demand, offline pinning, and background sync; verify actual Fedora Atomic and CLI/editor behavior before promising support. Require independent versioned backups, retention and key-recovery procedures, and client/server restore tests. Do not treat sync, virtual-file placeholders, or Git commits alone as a complete backup of user work.
- Keep active worktrees local until virtual-drive semantics are validated. Preserve source files and uncommitted work; exclude rebuildable dependencies, build outputs, model caches, and container layers from default backup sets. Keep proposed tooling clearly marked as planned until implemented and validated; milestone status belongs in PHASES.md.

## Signing

Never commit private signing keys; CI currently reads `SIGNING_SECRET`, and `cosign.pub` is public.
