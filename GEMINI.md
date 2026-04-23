# GEMINI.md

## Project Overview
This is a personal Neovim configuration written in Lua, designed to provide a lightweight yet powerful IDE-like experience for **Java**, **Go**, **TypeScript**, and **Rust** development.

### Core Technologies
- **Neovim 0.11+**: The core editor.
- **Lua**: Used for all configuration.
- **Packer.nvim**: Plugin management.
- **LSP (Language Server Protocol)**: Provided via `lsp-zero.nvim`, `mason.nvim`, and `nvim-lspconfig`.
- **Treesitter**: For advanced syntax highlighting and code understanding.
- **Telescope**: Fuzzy finder for files, git, and grep.

## Project Structure
The configuration follows a modular approach:

- `init.lua`: The entry point that loads the `felipe` module.
- `lua/felipe/`: Core configuration logic.
    - `init.lua`: Orchestrates the loading order: `remap` -> `packer` -> `set`.
    - `packer.lua`: Defines all plugins and their dependencies.
    - `remap.lua`: Global keybindings (Leader is `<Space>`).
    - `set.lua`: Standard Vim options (line numbers, indentation, etc.).
- `after/plugin/`: Plugin-specific configurations that are automatically loaded after plugins are initialized.
    - `lsp.lua`: Configuration for `lsp-zero`, `mason`, and `nvim-cmp`.
    - `telescope.lua`: Keybindings for the fuzzy finder.
    - `treesitter.lua`: Parser installation and highlighting setup.
    - `harpoon.lua`: Configuration for quick file navigation.
- `ftplugin/`: Filetype-specific configurations.
    - `java.lua`: Specialized setup for `nvim-jdtls` (handles Lombok and Spring Boot).
- `Makefile`: Automation for installing the configuration and `packer.nvim`.

## Installation and Maintenance

### Initial Setup
1. Clone the repository and run the install command:
   ```bash
   make install
   ```
2. Open Neovim and install plugins:
   ```vim
   :PackerSync
   ```

### Managing Plugins
- **Add Plugin**: Add a `use` statement in `lua/felipe/packer.lua`.
- **Sync**: Run `:PackerSync` to install new or remove unused plugins.

### Managing LSP Servers
LSP servers are managed via **Mason**:
- Open UI: `:Mason`
- Install Server: `:MasonInstall <server-name>`
- Recommended servers: `ts_ls`, `rust_analyzer`, `gopls`, `jdtls`, `spring-boot-tools`.

## Development Conventions

### Key Keymaps
- **Leader Key**: `<Space>`
- **Fuzzy Finder**: `<leader>pf` (files), `<C-p>` (git files), `<leader>ps` (grep).
- **LSP Actions**: `gd` (definition), `<leader>vca` (code actions), `<leader>vrn` (rename), `<leader>f` (format).
- **Navigation**: `<leader>a` (harpoon mark), `<C-h>` (harpoon menu), `<leader>1-9` (jump).
- **Git**: `<leader>gs` (Fugitive status).
- **Terminal**: `<C-F>` (tmux-sessionizer integration).

### LSP Strategy
- **Auto-enable**: Most LSPs (Go, TS, Rust) are auto-enabled via `mason-lspconfig` in `after/plugin/lsp.lua`.
- **Manual (Java)**: Java is explicitly excluded from `mason-lspconfig` auto-enable. It is configured in `ftplugin/java.lua` using `nvim-jdtls` to properly support project-specific workspaces and Lombok.

### Code Style
- Follows standard Lua patterns for Neovim.
- Prefer `after/plugin/` for any configuration that depends on a plugin being loaded.
- Use `remap.lua` for global bindings and `LspAttach` autocmds in `lsp.lua` for buffer-local LSP bindings.
