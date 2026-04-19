# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration written in Lua, namespaced under `lua/felipe/`. Plugin management is handled by **Packer.nvim**. Plugin-specific configuration lives in `after/plugin/` and is loaded automatically after plugins initialize.

## Architecture

```
init.lua                  # Single require("felipe") entry point
lua/felipe/
  init.lua                # Loads remap → packer → set (order matters)
  packer.lua              # All plugin declarations
  remap.lua               # Core keymaps (leader = space)
  set.lua                 # Editor options
after/plugin/             # Per-plugin configs, auto-loaded post-init
  lsp.lua                 # lsp-zero + mason + nvim-cmp setup
  telescope.lua           # Fuzzy finder keymaps
  harpoon.lua             # File bookmarks (<leader>1-9)
  fugitive.lua            # Git keymaps + autocmds
  treesitter.lua          # Parser installs + highlight
  colors.lua              # Colorscheme (Everforest, light)
  refactoring.lua         # Inline variable refactoring
plugin/packer_compiled.lua  # Auto-generated, do not edit
pack/github/start/copilot.vim/  # Manually installed (not via Packer)
```

## Plugin Management

To install/update plugins, open Neovim and run:

```
:PackerSync
```

To add a new plugin, add a `use` call in `lua/felipe/packer.lua` inside the `packer.startup` function, then run `:PackerSync`.

LSP servers, linters, and formatters are managed by **Mason**:

```
:Mason          # Open Mason UI to install/remove servers
:MasonInstall <server>
```

Currently configured LSP servers: `tsserver`, `rust_analyzer`.

## Key Keymaps Reference

Leader key: `<Space>`

| Keymap | Action |
|--------|--------|
| `<leader>pf` | Telescope: find files |
| `<C-p>` | Telescope: git files |
| `<leader>ps` | Telescope: live grep |
| `<leader>a` | Harpoon: add file |
| `<C-h>` | Harpoon: toggle menu |
| `<leader>1`–`9` | Harpoon: jump to bookmark |
| `<leader>gs` | Fugitive: git status |
| `<leader>f` | LSP: format buffer |
| `gd` | LSP: go to definition |
| `<leader>vca` | LSP: code actions |
| `<leader>vrn` | LSP: rename symbol |
| `<C-F>` | Launch `tmux-sessionizer` (external script) |
| `<leader>s` | Find & replace word under cursor (project-wide) |
| `<leader>y` / `<leader>Y` | Yank to system clipboard |

## LSP & Completion

`after/plugin/lsp.lua` wires together:
- **lsp-zero** (preset: "recommended") as the glue layer
- **mason.nvim** for server installation
- **nvim-cmp** for autocompletion with sources: `nvim_lsp`, `buffer`, `path`, `nvim_lua`, `luasnip`
- **LuaSnip** + `friendly-snippets` for snippets

When adding a new LSP server, install it via `:MasonInstall` and add it to the `lsp.ensure_installed` table in `after/plugin/lsp.lua`.

## External Dependencies

- **tmux** + a `tmux-sessionizer` script in `$PATH` (used by `<C-F>`)
- Tree-sitter CLI may be needed for compiling parsers (`brew install tree-sitter`)
