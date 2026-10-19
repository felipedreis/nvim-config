local status, ts = pcall(require, 'nvim-treesitter.configs')
if not status then
    return
end

ts.setup {
  ensure_installed = { "vimdoc", "javascript", "typescript", "c", "lua", "rust", "markdown", "markdown_inline" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    -- CRITICAL: Disable nvim-treesitter highlighting for markdown.
    -- This prevents the "range (a nil value)" crash on Neovim 0.12
    -- while still allowing render-markdown.nvim to function.
    disable = { "markdown" },
    additional_vim_regex_highlighting = false,
  },
}
