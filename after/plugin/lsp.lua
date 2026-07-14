local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('*', {
    capabilities = capabilities,
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf, remap = false }
        local tb = require('telescope.builtin')
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gu", tb.lsp_references, opts)
        vim.keymap.set("n", "gi", tb.lsp_implementations, opts)
        vim.keymap.set("n", "gy", tb.lsp_type_definitions, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vds", tb.lsp_document_symbols, opts)
        vim.keymap.set("n", "<leader>vws", tb.lsp_dynamic_workspace_symbols, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>vrr", tb.lsp_references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
    end,
})

require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = { 'ts_ls', 'rust_analyzer', 'gopls' },
    automatic_enable = {
        exclude = { 'jdtls', 'java_language_server' }, -- java managed by nvim-jdtls via ftplugin/java.lua
    },
})

vim.diagnostic.config({
    virtual_text = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = 'E',
            [vim.diagnostic.severity.WARN]  = 'W',
            [vim.diagnostic.severity.HINT]  = 'H',
            [vim.diagnostic.severity.INFO]  = 'I',
        },
    },
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>']     = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>']     = cmp.mapping.select_next_item(cmp_select),
        ['<CR>']      = cmp.mapping.confirm({ select = false }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
})
