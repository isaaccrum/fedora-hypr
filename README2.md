# Hypratomic — Phase 1

A conservative Fedora Atomic / BlueBuild starting point for an
**Omarchy-inspired Hyprland desktop**.

The first milestone is intentionally not flashy. It gives us a custom signed
Atomic image that boots a known-working Wayblue Hyprland session, adds
Quickshell and a few basic tools, and creates a safe place for our later
configuration without touching the active desktop.

## Why start this way?

The project has two different kinds of state:

1. **OS state** — RPM packages, system files, policies, and common defaults.
   These belong in the BlueBuild image.
2. **User/machine state** — monitor layout, personal overrides, credentials,
   and active dotfiles. These belong under `$HOME` and should not be silently
   overwritten by an image update.

Keeping those separate lets the Atomic deployment/rollback model do its job
without pretending that the user's home directory is immutable.

## Current base

```yaml
base-image: ghcr.io/wayblueorg/hyprland
image-version: latest
```

Wayblue currently documents `latest` as its supported rebase tag. This means
Phase 1 intentionally follows Wayblue's current Hyprland base rather than
pinning a Fedora major version ourselves. That is convenient, but it is also
the biggest reproducibility compromise in this design. Once the desktop is
mature we can decide whether to continue following Wayblue or own the Fedora
44/45 Hyprland layer directly.

## What Phase 1 changes

The image adds:

- `quickshell`
- `foot`
- `btop`
- `fastfetch`
- `fzf`
- `ripgrep`
- `fd-find`
- `hypratomic-doctor`
- `hypratomic-bootstrap`

It does **not** replace Hyprland configuration, Waybar, SDDM, portals, or other
Wayblue desktop components.

## Recommended repository setup

The safest setup is to create the GitHub repository using the official
BlueBuild template or BlueBuild Workshop so that signing is configured for
you, then copy this repository's `recipes/` and `files/` content into it.

This starter also includes a minimal current GitHub Actions workflow. It expects
these GitHub Actions secrets:

- `COSIGN_PRIVATE_KEY`
- `COSIGN_PUBLIC_KEY`

Never commit `cosign.key`.

## Local validation before publishing

From the repository root:

```bash
bluebuild generate ./recipes/recipe.yml -o Containerfile
bluebuild build ./recipes/recipe.yml
```

If you are already running Fedora Atomic and intentionally want to test the
locally built image on that machine, BlueBuild also provides:

```bash
bluebuild switch ./recipes/recipe.yml
```

Do this only on a test machine/installation for the first iteration.

## Publishing

Push to the `main` branch. The included workflow publishes the image to:

```text
ghcr.io/<YOUR-GITHUB-USER>/hypratomic:latest
```

Check that the GitHub Actions run completed successfully before rebasing.

## First rebase from Fedora Atomic

Replace `<YOUR-GITHUB-USER>` below.

### 1. Rebase once without signature enforcement

This first deployment installs the signing policy/public key carried by the
image:

```bash
sudo rpm-ostree rebase \
  ostree-unverified-registry:ghcr.io/<YOUR-GITHUB-USER>/hypratomic:latest
sudo systemctl reboot
```

### 2. Verify the first boot

Do not customize anything yet.

```bash
rpm-ostree status
hypratomic-doctor
```

Log into Hyprland and verify at least:

- terminal launches;
- network works;
- audio works;
- Waybar works;
- suspend/resume works if this is a laptop;
- Flatpaks still launch;
- a browser can screen-share if that matters to you.

### 3. Switch to the signed image

```bash
sudo rpm-ostree rebase \
  ostree-image-signed:docker://ghcr.io/<YOUR-GITHUB-USER>/hypratomic:latest
sudo systemctl reboot
```

Then run again:

```bash
rpm-ostree status
hypratomic-doctor
```

## Prove rollback before doing anything clever

Before Phase 2, make sure you know the recovery path:

```bash
rpm-ostree status
sudo rpm-ostree rollback
sudo systemctl reboot
```

That stages the previous deployment as the next boot. You can also select a
previous deployment from the boot menu when needed.

After proving rollback, return to the desired deployment/update normally.

## Bootstrap the future configuration tree

Once Phase 1 is healthy:

```bash
hypratomic-bootstrap
```

This creates:

```text
~/.config/hypratomic/
├── README.md
├── hypr/
└── quickshell/
```

It **does not touch**:

```text
~/.config/hypr/
~/.config/waybar/
~/.config/quickshell/
```

That is deliberate. Phase 2 will add an explicit activation helper that backs
up the working Wayblue configuration before switching to ours.

## Repository layout

```text
hypratomic/
├── .github/workflows/build.yml
├── recipes/
│   └── recipe.yml
├── files/system/
│   └── usr/
│       ├── bin/
│       │   ├── hypratomic-bootstrap
│       │   └── hypratomic-doctor
│       └── share/hypratomic/defaults/
│           ├── README.md
│           ├── hypr/
│           └── quickshell/
├── PHASES.md
└── README.md
```

## Phase 1 exit checklist

Do not proceed to the Omarchy configuration until all of these are true:

- [ ] GitHub build succeeds.
- [ ] First unsigned rebase succeeds.
- [ ] Signed rebase succeeds.
- [ ] Hyprland session starts normally twice in a row.
- [ ] `hypratomic-doctor` reports no failures.
- [ ] Network/audio/basic desktop behavior works.
- [ ] You have successfully tested `rpm-ostree rollback`.
- [ ] You have returned to the Hypratomic deployment afterward.

Then proceed to Phase 2 in `PHASES.md`.
