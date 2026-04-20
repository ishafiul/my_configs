# Tmux Basic Commands

Prefix key is `Ctrl+b` by default.

## Sessions
- New session (outside tmux): `tmux new -s main`
- New session (inside tmux): `prefix` then `:` then `new-session -s main`
- New detached session (inside/outside): `tmux new-session -d -s main`
- List sessions: `tmux ls`
- Switch session (inside tmux): `prefix` then `s` (session picker)
- Switch to named session (inside tmux): `prefix` then `:` then `switch-client -t main`
- Next session (inside tmux): `prefix` then `)`
- Previous session (inside tmux): `prefix` then `(`
- Rename current session (inside tmux): `prefix` then `$`
- Rename session (inside tmux command mode): `prefix` then `:` then `rename-session new_name`
- Rename session (from shell): `tmux rename-session -t old_name new_name`
- Attach to session (outside tmux): `tmux attach -t main`
- Detach from session: `prefix` then `d`
- Kill session: `tmux kill-session -t main`

## Windows
- New window: `prefix` then `c`
- Next window: `prefix` then `n`
- Previous window: `prefix` then `p`
- Go to window number: `prefix` then `0-9`
- Rename window: `prefix` then `,`
- Close window: `prefix` then `&`

## Panes
- Split horizontal: `prefix` then `"`
- Split vertical: `prefix` then `%`
- Move between panes: `prefix` then arrow keys
- Resize pane: `prefix` then `Ctrl+arrow keys`
- Zoom/unzoom pane: `prefix` then `z`
- Close pane: `prefix` then `x`

## Copy/Scroll Mode
- Enter copy mode: `prefix` then `[`
- Move in copy mode (vi keys enabled): `h j k l`
- Start selection in copy mode: `Space`
- Copy selection and exit: `Enter`

## Plugins (TPM)
- Install plugins: `prefix` then `I`
- Update plugins: `prefix` then `U`
- Remove unused plugins: `prefix` then `Alt+u`

## Useful in this setup
- Auto-start tmux in Ghostty is enabled via `ghostty` config.
- Reopen/restore workflow uses `tmux-resurrect` and `tmux-continuum`.
