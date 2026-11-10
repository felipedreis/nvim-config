-- Installs the non-LSP Mason packages this config depends on (debuggers etc.), so a fresh
-- machine only needs the plugins (:PackerSync) and a restart. LSP servers are handled by
-- mason-lspconfig in lsp.lua. Already-installed packages are skipped.
local ok, registry = pcall(require, 'mason-registry')
if not ok then return end

local tools = {
    'jdtls',              -- Java language server (ftplugin/java.lua)
    'java-debug-adapter', -- Java debugging
    'java-test',          -- Java test debugging (<leader>T / <leader>C)
    'delve',              -- Go debugging (dlv)
}

registry.refresh(function()
    for _, name in ipairs(tools) do
        local found, pkg = pcall(registry.get_package, name)
        if found and not pkg:is_installed() and not pkg:is_installing() then
            vim.notify('Mason: installing ' .. name)
            pkg:install()
        end
    end
end)
