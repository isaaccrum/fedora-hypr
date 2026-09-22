# Phase 5 Distrobox environments

The host image includes Distrobox and the editor/multiplexer workflow, but it
does not include language toolchains or native build dependencies. The managed
manifest provides two starting points:

Podman is an explicit host dependency and runs rootlessly as the logged-in user.
Before creating the first environment, confirm that the account has entries in
`/etc/subuid` and `/etc/subgid`; then run `podman info` and a disposable
`podman run --rm quay.io/podman/hello`. `hypratomic-doctor` reports missing
subordinate ranges as a warning because those ranges belong to the deployed
machine rather than the image.

```bash
hypratomic-devbox create rust
hypratomic-devbox enter rust

hypratomic-devbox create typescript
hypratomic-devbox enter typescript
```

The Rust profile contains the Fedora Rust compiler, Cargo, rustfmt, Clippy,
rust-analyzer, and native build tools. The TypeScript profile contains Node.js,
npm, Python, and native build tools; each project records its TypeScript,
formatter, linter, and dependency versions in `package.json` and its lockfile.

Use the project directory from the host, then run the editor and tests inside
the matching container. Distrobox shares the home directory and is not a
security sandbox. Containers can be recreated without changing source files:

```bash
hypratomic-devbox list
hypratomic-devbox remove rust
hypratomic-devbox create rust
```

The image tag `registry.fedoraproject.org/fedora-toolbox:44` records the major
base release. Before calling the environments reproducible, record a digest for
that image and commit each project's Cargo or npm lockfile. Dependency downloads
and container image layers remain outside the host image and should not be
included in default user-file backups.
