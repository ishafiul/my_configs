# LazyVim Basic Commands

## Global
- Open Neovim: `nvim`
- Quit: `:q`
- Save: `:w`
- Save and quit: `:wq`
- Force quit: `:q!`
- Undo: `u`
- Redo: `Ctrl-r`

## Lazy Plugin Manager
- Open Lazy UI: `:Lazy`
- Sync plugins: `:Lazy sync`
- Update plugins: `:Lazy update`
- Clean removed plugins: `:Lazy clean`
- Check plugin health: `:checkhealth lazy`

## File and Search (Telescope/Snacks)
- Find files: `<leader><space>`
- Live grep text: `<leader>/`
- Recent files: `<leader>fr`
- Buffers: `<leader>,`
- Show project file tree: `<leader>e` (`Space e`)
- Hide project file tree: `Esc` while explorer is focused
- Show symbol docs: hold mouse over a class, method, or property for 0.5 seconds
- Show symbol docs manually: `K`
- Copy docs text: click popup, `v` to select, then `y` to copy
- Copy docs text to macOS clipboard: `"+y`

## LSP / Code
- Go to definition: `gd`
- Go to references: `gr`
- Hover docs: `K`
- Rename symbol: `<leader>cr`
- Code actions: `<leader>ca`
- Format file: `<leader>cf`

## Flutter
- Open one-line Flutter controls: `<leader>F` (`Space Shift+f`)
- Run Flutter: `F5`
- First available Flutter device and first Dart launch configuration select automatically
- Choose device: click `[⌁ Device]` or use `:FlutterDevices`
- Choose `.vscode/launch.json` config: click `[⚙ Config]` or use `:FlutterConfig`
- Launch emulator: click `[▣ Emulator]` or use `:FlutterEmulators`
- Run selected device: click `[▶ Run]` or use `:FlutterRun`
- Run/log terminal: opens in a bottom panel and closes when the app stops
- Hot reload: click `[↻ Reload]` or use `:FlutterReload`
- Hot restart: click `[⟳ Restart]` or use `:FlutterRestart`
- Stop app: click `[■ Stop]` or use `:FlutterStop`

## Diagnostics
- Next diagnostic: `]d`
- Previous diagnostic: `[d`
- Diagnostics list: `<leader>xx`

## Windows / Tabs / Buffers
- Split vertical: `<leader>|`
- Split horizontal: `<leader>-`
- Move window focus: `Ctrl+h/j/k/l`
- New tab: `<leader><tab>n`
- Next tab: `<leader><tab>l`
- Previous tab: `<leader><tab>h`
- Close buffer: `<leader>bd`

## Git (basic)
- Git status UI: `<leader>gg`
- Next hunk: `]h`
- Prev hunk: `[h`
- Stage hunk: `<leader>ghs`
- Reset hunk: `<leader>ghr`

## Helpful notes
- Leader key is `Space`.
- Use `:LazyVimHealth` to verify full setup.
- If mappings differ, run `:map <leader>` or check `:Lazy` keymaps.
