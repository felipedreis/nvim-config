local status, ts = pcall(require, 'nvim-treesitter')
if not status then
    return
end

-- nvim-treesitter `main` branch: no more `nvim-treesitter.configs`.
-- Parsers are installed explicitly (async) and highlighting is enabled per-buffer.
ts.setup {}

local parsers = { "vimdoc", "javascript", "typescript", "c", "lua", "rust", "markdown", "markdown_inline" }
ts.install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    -- Skip markdown: avoids the "range (a nil value)" crash on newer Neovim
    -- while still allowing render-markdown.nvim to function.
    if args.match == 'markdown' then
      return
    end
    pcall(vim.treesitter.start, args.buf)
  end,
})
