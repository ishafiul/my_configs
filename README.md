# My Configs

Personal macOS dev environment for Aerospace, tmux, Ghostty, and LazyVim.

## Setup

```bash
git clone https://github.com/ishafiul/my_configs.git
cd my_configs
./install.sh
```

## What `install.sh` does

- Installs missing Homebrew tools: `git`, `tmux`, `neovim`, `ripgrep`, `fd`, `tree-sitter`, `stylua`
- Installs apps/fonts: `Ghostty`, `Aerospace`, `Hurmit Nerd Font`
- Installs `asdf` (if missing) and configures plugins for `nodejs`, `flutter`, `pnpm`
- Installs runtime versions from this repo
- Installs tmux plugin manager (`tpm`)
- Creates symlinks:
  - `aerospace.toml` -> `~/.aerospace.toml`
  - `.tmux.conf` -> `~/.tmux.conf`
  - `ghostty` -> `~/.config/ghostty/config`
  - `nvim` -> `~/.config/nvim`

## Runtime versions

Pinned in `.tool-versions`:

- `nodejs 25.9.0`
- `flutter 3.41.7-stable`
- `pnpm` (resolved to latest available via asdf during install)

## Neovim highlights

- LazyVim-based setup with TypeScript, JSON, Tailwind, and Flutter tooling
- JS/TS/JSON formatting via Biome (`conform.nvim` uses `biome`)
- LSP managed through Mason + `nvim-lspconfig`

## After install

- Reload Aerospace config: `aerospace reload-config`
- In tmux, install plugins: `prefix + I`
- Open `nvim` once and run `:Lazy sync`
- Optional health checks: `:checkhealth` and `:LazyVimHealth`

## Command references

- LazyVim cheatsheet: `LAZYVIM_COMMANDS.md`
- tmux cheatsheet: `TMUX_COMMANDS.md`
