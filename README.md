# nvim config

Personal Neovim configuration written in Lua. Aims to replace IDEs for Java, Go, TypeScript, and Rust development.

## Requirements

- Neovim 0.11+
- [Packer.nvim](https://github.com/wbthomason/packer.nvim)
- Node.js (ts_ls)
- Go 1.25+ (gopls)
- Java 17+ (jdtls)
- Python 3 (jdtls launcher)
- tmux + `tmux-sessionizer` script in `$PATH`

## Installation

```bash
git clone <repo> ~/.config/nvim
```

Open Neovim and install plugins:

```
:PackerSync
```

Install LSP servers:

```
:MasonInstall ts_ls rust_analyzer gopls jdtls spring-boot-tools
```

## Plugin manager

Plugins are declared in `lua/felipe/packer.lua`. After any change run `:PackerSync`.

LSP servers, linters, and formatters are managed separately by Mason (`:Mason`).

## Key keymaps

Leader key: `<Space>`

| Keymap | Action |
|--------|--------|
| `<leader>pf` | Find files |
| `<C-p>` | Git files |
| `<leader>ps` | Live grep |
| `<leader>a` | Harpoon: mark file |
| `<C-h>` | Harpoon: menu |
| `<leader>1`–`9` | Harpoon: jump to mark |
| `<leader>gs` | Git status (Fugitive) |
| `gd` | LSP: go to definition |
| `gb` | Jump back |
| `<leader>vca` | LSP: code actions |
| `<leader>vrn` | LSP: rename |
| `<leader>f` | LSP: format buffer |
| `<leader>s` | Find & replace word under cursor |
| `<leader>y` / `<leader>Y` | Yank to system clipboard |
| `<C-F>` | tmux-sessionizer |

## LSP support

| Language | Server | Notes |
|----------|--------|-------|
| Java | jdtls (nvim-jdtls) | Lombok + Spring Boot Tools support |
| TypeScript | ts_ls | |
| Rust | rust_analyzer | |
| Go | gopls | |

Java is configured via `ftplugin/java.lua` using `nvim-jdtls` directly (not mason auto-enable) to support Lombok annotations and `jdt://` class file navigation.
