-- Per-project workspace so jdtls doesn't mix state across projects
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

local lombok_jar = vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/lombok.jar')

local bundles = {}
local spring_jar = vim.fn.glob(
    vim.fn.expand('~/.local/share/nvim/mason/packages/spring-boot-tools/extension/language-server/spring-boot-language-server-*.jar')
)
if spring_jar ~= '' then
    vim.list_extend(bundles, { spring_jar })
end

local config = {
    cmd = {
        vim.fn.expand('~/.local/share/nvim/mason/bin/jdtls'),
        '--jvm-arg=-javaagent:' .. lombok_jar,
        '-data', workspace_dir,
    },

    root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts' }),

    settings = {
        java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = 'fernflower' },
            completion = {
                favoriteStaticMembers = {},
                filteredTypes = { 'com.sun.*', 'sun.*', 'java.awt.*', 'jdk.*' },
            },
            sources = {
                organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
            },
        },
    },

    -- Enables jumping into jdt:// URIs (library/JDK class files)
    capabilities = require('cmp_nvim_lsp').default_capabilities(),

    init_options = {
        bundles = bundles,
    },
}

require('jdtls').start_or_attach(config)
