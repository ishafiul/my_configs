# LazyVim Basic Commands

## Global
- Open Neovim: `nvim`
- Quit: `:q`
- Save: `:w`
- Save and quit: `:wq`
- Force quit: `:q!`

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
- File explorer: `<leader>e`

## LSP / Code
- Go to definition: `gd`
- Go to references: `gr`
- Hover docs: `K`
- Rename symbol: `<leader>cr`
- Code actions: `<leader>ca`
- Format file: `<leader>cf`

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
