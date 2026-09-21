# Phase 2b keymap and workflow audit

This is the supported input ownership for the initial coding workflow:

| Layer | Owner | Reserved input | Notes |
|---|---|---|---|
| Hyprland | Desktop/session | `Super` combinations, `Print`, media keys | Desktop actions launch Foot, Yazi, Wofi, screenshots, and the keybind viewer. |
| Foot | Terminal | Terminal-emulator defaults | Foot does not claim the Tmux prefix or Neovim leader. |
| Tmux | Multiplexer | `Ctrl-a` prefix, then pane/session commands | Pane movement uses prefix plus arrows. Direct `Ctrl-h/j/k/l` remains available to Neovim and shell programs. |
| Neovim/LazyVim | Editor | Modal keys and the editor leader | The editor owns its buffer, split, completion, and terminal mappings. |
| AI plugin | Editor subgroup | Reserved leader subgroup only after plugin audit | AI mappings must remain optional and project-scoped. |

The current Tmux starting point is installed by `hypratomic-coding-bootstrap` only
when the user has no existing `~/.config/tmux/tmux.conf`. Image updates never
replace that file. Herder remains an evaluation candidate and is not part of the
supported baseline.

## Verification procedure

Run these checks on a deployed image after logging into Hyprland:

1. Run `hypratomic-coding-bootstrap`; confirm an existing Tmux configuration is
   preserved and a missing configuration is created with mode `0600`.
2. Launch Foot, start `tmux`, and run `nvim` in a project directory.
3. Check `Super+Return`, `Super+Shift+F`, `Super+K`, and
   `Ctrl+Super+K`; each should open the documented action without changing the
   Tmux prefix or editor state.
4. In Neovim, test normal, insert, terminal, and command-line modes. Confirm
   `Ctrl-h/j/k/l` remains available to the editor or shell as configured.
5. In Tmux, test `Ctrl-a` followed by pane splits, pane movement, window creation,
   reload, copy mode, and resize. Test both keyboard and clipboard paste.
6. Start a nested Tmux session and repeat the prefix test; the inner session must
   receive the forwarded prefix.
7. Connect to a project over SSH and repeat editor, pane, and clipboard checks.
8. Run `tmux list-keys` and `nvim --clean`; record any user or distribution
   mappings that require an explicit unbind/rebind.

A binding is considered clear only after the complete Foot → Tmux → Neovim path
has been tested. Hyprland's live list alone cannot establish that there are no
conflicts in editor, shell, copy, or nested-session modes.
