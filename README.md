## Setup
```bash
git clone https://github.com/ishafiul/my_configs.git
```
```bash
cd my_configs
```
## Install tmux

```bash
brew install tmux
```
## Setup tpm

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Setup tmux config

```bash
ln -s $(pwd)/.tmux.conf ${HOME}/.tmux.conf
```

### Setup Plugins

```
tmux
<prefix>I
```

## Install Alacritty

```bash
brew install --cask alacritty
```

## Setup Alacritty

```bash
mkdir -p ${HOME}/.config/alacritty
```

```bash
ln -s $(pwd)/alacritty.yml ${HOME}/.config/alacritty/alacritty.yml
```

## Install Aerospace

```bash
brew install --cask nikitabobko/tap/aerospace
```

## Setup Aerospace

```bash
ln -s $(pwd)/.aerospace.toml ${HOME}/.aerospace.toml
```