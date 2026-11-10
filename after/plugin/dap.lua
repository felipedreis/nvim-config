local ok, dap = pcall(require, 'dap')
if not ok then return end
local dapui = require('dapui')

-- Layout 1: variables sidebar. Layout 2: bottom output tray (not used for the Gradle
-- session, whose own terminal split is the log view).
dapui.setup({
    layouts = {
        { elements = { 'scopes', 'breakpoints', 'stacks', 'watches' }, size = 40, position = 'left' },
        { elements = { 'repl', 'console' }, size = 12, position = 'bottom' },
    },
})
pcall(function() require('dap-go').setup() end) -- Go via delve (:MasonInstall delve)
dap.set_log_level('INFO') -- raise to 'TRACE' when debugging the debugger; view with :DapShowLog

-- Open/close the UI automatically with the debug session
dap.listeners.after.event_initialized['dapui_config'] = function(session)
    if session.config.name == 'gradle bootRun' then dapui.open(1) else dapui.open() end
end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'Visual' })

-- Step out is <leader>x, defined buffer-locally in ftplugin/java.lua
-- (global <leader>x is chmod +x in remap.lua)
-- Continue if a session is active. Otherwise:
--  * Spring Boot Gradle module: `./gradlew <module>:bootRun --debug-jvm`, then attach
--  * other Java (Maven, plain, non-Boot Gradle): launch via jdtls, preferring the main
--    class of the current file, else the only main class, else the picker
--  * Go: debug the package of the current file with delve
-- `.env.local` in the project root is passed as environment in every case.
local gradle = require('felipe.gradle_debug')
dap.defaults.java.terminate_debuggee = true -- <leader>q also kills the attached app
dap.listeners.after.disconnect['gradle_debug'] = function() gradle.stop() end

-- Java config whose main class is the file in the current buffer, if any
local function current_file_main()
    local file = vim.api.nvim_buf_get_name(0)
    for _, c in ipairs(dap.configurations.java or {}) do
        if c.mainClass and vim.endswith(file, '/' .. (c.mainClass:gsub('%.', '/')) .. '.java') then
            return c
        end
    end
end

vim.keymap.set('n', '<leader>c', function()
    if not dap.session() then
        local ft = vim.bo.filetype
        if ft == 'java' then
            if gradle.start() then return end -- Spring Boot Gradle module: bootRun + attach
            -- Maven / plain Java / non-Boot Gradle: launch through jdtls
            local cfg = current_file_main()
            if not cfg then
                local mains = vim.tbl_filter(function(c) return c.mainClass end, dap.configurations.java or {})
                if #mains == 1 then cfg = mains[1] end
            end
            if cfg then return dap.run(cfg) end
        elseif ft == 'go' then
            local root = vim.fs.root(0, { 'go.mod', '.git' })
            return dap.run({
                type = 'go',
                request = 'launch',
                name = 'Debug package',
                program = vim.fn.expand('%:p:h'),
                env = gradle.load_env(root),
            })
        end
    end
    dap.continue()
end, { desc = 'DAP: continue / start' })
vim.keymap.set('n', '<leader>o', dap.step_over, { desc = 'DAP: step over' })
vim.keymap.set('n', '<leader>i', dap.step_into, { desc = 'DAP: step into' })
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'DAP: toggle breakpoint' })
vim.keymap.set('n', '<leader>B', function()
    dap.set_breakpoint(vim.fn.input('Condition: '))
end, { desc = 'DAP: conditional breakpoint' })
vim.keymap.set('n', '<leader>u', dapui.toggle, { desc = 'DAP: toggle UI' })
vim.keymap.set({ 'n', 'v' }, '<leader>?', function() dapui.eval() end, { desc = 'DAP: eval expression' })
vim.keymap.set('n', '<leader>q', dap.terminate, { desc = 'DAP: terminate session' })
vim.keymap.set('n', '<leader>Q', function()
    local s = dap.status()
    vim.notify(s ~= '' and s or (dap.session() and 'Session running' or 'No active session'))
end, { desc = 'DAP: session status' })
