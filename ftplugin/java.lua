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

-- Single source of truth for the JDK: JAVA_HOME (set by SDKMAN), falling back to its "current" symlink
local java_home = os.getenv('JAVA_HOME') or vim.fn.expand('~/.sdkman/candidates/java/current')
local java_major = (vim.fn.system({ java_home .. '/bin/java', '-version' }) or ''):match('version "(%d+)') or '25'

-- Debug adapter (install with :MasonInstall java-debug-adapter java-test)
local mason_pkgs = vim.fn.expand('~/.local/share/nvim/mason/packages')
local debug_jars = vim.fn.glob(mason_pkgs .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar')
if debug_jars ~= '' then
    vim.list_extend(bundles, vim.split(debug_jars, '\n'))
end
local test_jars = vim.fn.glob(mason_pkgs .. '/java-test/extension/server/*.jar')
if test_jars ~= '' then
    -- These two are loaded by the test runner itself, not as jdtls bundles
    local excluded = {
        ['com.microsoft.java.test.runner-jar-with-dependencies.jar'] = true,
        ['jacocoagent.jar'] = true,
    }
    for _, jar in ipairs(vim.split(test_jars, '\n')) do
        if not excluded[vim.fn.fnamemodify(jar, ':t')] then
            table.insert(bundles, jar)
        end
    end
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
            -- Workspace-wide JDT compiler prefs (emits -parameters, see file)
            settings = { url = vim.fn.stdpath('config') .. '/jdtls/java-settings.prefs' },
            configuration = {
                runtimes = {
                    { name = 'JavaSE-' .. java_major, path = java_home, default = true },
                },
            },
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

    on_attach = function(client, bufnr)
        local jdtls = require('jdtls')
        jdtls.setup_dap({ hotcodereplace = 'auto' })
        -- Per-project env: if <root>/.env.local exists, its KEY=VALUE lines are
        -- passed as environment variables to every discovered main-class launch config.
        require('jdtls.dap').setup_dap_main_class_configs({
            on_ready = function()
                local env = require('felipe.gradle_debug').load_env(client.config.root_dir)
                if next(env) == nil then return end
                for _, c in ipairs(require('dap').configurations.java or {}) do
                    if c.mainClass then c.env = vim.tbl_extend('force', c.env or {}, env) end
                end
            end,
        })

        -- Step out: <leader>x shadows the global chmod +x mapping, Java buffers only
        vim.keymap.set('n', '<leader>x', function() require('dap').step_out() end,
            { buffer = bufnr, desc = 'DAP: step out' })
        vim.keymap.set('n', '<leader>C', jdtls.test_class, { buffer = bufnr, desc = 'Java: debug test class' })
        vim.keymap.set('n', '<leader>T', jdtls.test_nearest_method, { buffer = bufnr, desc = 'Java: debug nearest test method' })
    end,
}

require('jdtls').start_or_attach(config)
