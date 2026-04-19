#!/bin/bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing configs from $CONFIG_DIR"

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed."
    echo "Please install Homebrew first: https://brew.sh"
    exit 1
fi

install_formula_if_missing() {
    local binary="$1"
    local formula="$2"
    if ! command -v "$binary" >/dev/null 2>&1; then
        echo "Installing $formula..."
        brew install "$formula"
    else
        echo "$formula already installed"
    fi
}

ensure_asdf() {
    if ! command -v asdf >/dev/null 2>&1; then
        echo "Installing asdf..."
        brew install asdf
    else
        echo "asdf already installed"
    fi

    if ! command -v asdf >/dev/null 2>&1; then
        if [ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]; then
            # shellcheck disable=SC1091
            . "/opt/homebrew/opt/asdf/libexec/asdf.sh"
        fi
    fi

    if ! command -v asdf >/dev/null 2>&1; then
        echo "asdf is installed but not available in this shell."
        echo "Please add asdf to your shell config and re-run install.sh"
        exit 1
    fi
}

ensure_asdf_plugin() {
    local plugin="$1"
    local repo="$2"
    if ! asdf plugin list | grep -qx "$plugin"; then
        echo "Adding asdf plugin: $plugin"
        asdf plugin add "$plugin" "$repo"
    fi
}

install_asdf_tool() {
    local tool="$1"
    local version="$2"
    if ! asdf where "$tool" "$version" >/dev/null 2>&1; then
        echo "Installing $tool $version via asdf..."
        asdf install "$tool" "$version"
    else
        echo "$tool $version already installed"
    fi
    asdf set -u "$tool" "$version"
}

install_cask_if_missing() {
    local app_name="$1"
    local cask="$2"
    if [ ! -d "/Applications/$app_name.app" ]; then
        echo "Installing $cask..."
        brew install --cask "$cask"
    else
        echo "$app_name already installed"
    fi
}

# Core tools
install_formula_if_missing git git
install_formula_if_missing tmux tmux
install_formula_if_missing nvim neovim
install_formula_if_missing rg ripgrep
install_formula_if_missing fd fd
install_formula_if_missing tree-sitter tree-sitter
install_formula_if_missing stylua stylua

# asdf-managed dev runtimes
ensure_asdf
ensure_asdf_plugin nodejs https://github.com/asdf-vm/asdf-nodejs.git
ensure_asdf_plugin flutter https://github.com/oae/asdf-flutter.git
ensure_asdf_plugin pnpm https://github.com/jonathanmorley/asdf-pnpm.git

install_asdf_tool nodejs 25.9.0
install_asdf_tool flutter 3.41.7-stable

pnpm_version="$(asdf latest pnpm 2>/dev/null || true)"
if [ -n "$pnpm_version" ]; then
    install_asdf_tool pnpm "$pnpm_version"
else
    echo "Could not resolve latest pnpm with asdf."
    echo "After nodejs is installed, run: asdf install pnpm <version>"
fi

asdf reshim nodejs 25.9.0 || true
asdf reshim flutter 3.41.7-stable || true
if [ -n "$pnpm_version" ]; then
    asdf reshim pnpm "$pnpm_version" || true
fi

# Apps
install_cask_if_missing Ghostty ghostty

if ! command -v aerospace >/dev/null 2>&1; then
    echo "Installing aerospace..."
    if ! brew install --cask nikitabobko/tap/aerospace; then
        brew tap nikitabobko/tap
        brew install --cask aerospace
    fi
else
    echo "aerospace already installed"
fi

# Fonts
if [ ! -f "$HOME/Library/Fonts/HurmitNerdFontMono-Regular.otf" ]; then
    echo "Installing Hurmit Nerd Font..."
    brew install --cask font-hurmit-nerd-font
else
    echo "Hurmit Nerd Font already installed"
fi

# Tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing tmux plugin manager..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "tpm already installed"
fi

echo "Creating symlinks..."
ln -sf "$CONFIG_DIR/aerospace.toml" "$HOME/.aerospace.toml"
ln -sf "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$CONFIG_DIR/ghostty" "$HOME/.config/ghostty/config"

# LazyVim / Neovim config
mkdir -p "$HOME/.config"
if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    backup_path="$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
    echo "Existing ~/.config/nvim found. Backing up to $backup_path"
    mv "$HOME/.config/nvim" "$backup_path"
fi
ln -sfn "$CONFIG_DIR/nvim" "$HOME/.config/nvim"

echo "Done."
echo "- Reload aerospace: aerospace reload-config"
echo "- Install tmux plugins inside tmux: prefix + I"
echo "- Open nvim once to let LazyVim install plugins"
