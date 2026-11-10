local M = {}

local PORT = 5005

--- Parse <root>/.env.local (KEY=VALUE, optional `export`, optional quotes) into a table.
function M.load_env(root)
    local env = {}
    local f = root and io.open(root .. '/.env.local', 'r')
    if not f then return env end
    for line in f:lines() do
        line = line:gsub('^%s*export%s+', '')
        local k, v = line:match('^%s*([%w_]+)%s*=%s*(.-)%s*$')
        if k and not line:match('^%s*#') then
            env[k] = v:match('^"(.*)"$') or v:match("^'(.*)'$") or v
        end
    end
    f:close()
    return env
end

--- Project root if it is a Gradle project with a wrapper, else nil.
function M.gradle_root()
    return vim.fs.root(0, { 'gradlew' })
end

local function mentions_boot(path)
    local f = io.open(path, 'r')
    if not f then return false end
    local text = f:read('*a')
    f:close()
    return text:find('org.springframework.boot', 1, true) ~= nil
end

--- Gradle task path for the Spring Boot module owning the current buffer, e.g. ':service:bootRun'.
--- Walks up from the file to the nearest dir with a build.gradle(.kts), below the root.
--- Returns nil when that module does not apply the Spring Boot plugin.
local function boot_task(root)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    while dir and #dir >= #root do
        for _, name in ipairs({ 'build.gradle', 'build.gradle.kts' }) do
            local build = dir .. '/' .. name
            if vim.uv.fs_stat(build) then
                if not mentions_boot(build) then return nil end
                if #dir == #root then return 'bootRun' end
                local rel = dir:sub(#root + 2):gsub('/', ':')
                return ':' .. rel .. ':bootRun'
            end
        end
        dir = vim.fs.dirname(dir)
    end
    return nil
end

local job, term_buf = nil, nil

--- Run `./gradlew <module>:bootRun --debug-jvm` in a terminal split, then attach once the JVM listens.
function M.start()
    local dap = require('dap')
    local root = M.gradle_root()
    if not root then return false end

    local task = boot_task(root)
    if not task then return false end

    M.stop()
    vim.cmd('botright 15new')
    local buf = vim.api.nvim_get_current_buf()
    term_buf = buf
    local out, attached = '', false
    job = vim.fn.termopen({ './gradlew', task, '--debug-jvm' }, {
        cwd = root,
        env = M.load_env(root),
        on_stdout = function(_, data)
            if attached then return end
            out = out .. table.concat(data, '\n')
            if out:find('Listening for transport dt_socket', 1, true) then
                attached = true
                vim.schedule(function()
                    dap.run({
                        type = 'java',
                        request = 'attach',
                        name = 'gradle bootRun',
                        hostName = '127.0.0.1',
                        port = PORT,
                        -- Attach needs no classpath. nvim-jdtls resolves these through jdtls
                        -- unless they are all set, and fails on Gradle root projects
                        -- ("Model not available"), so pre-fill them to skip that step.
                        mainClass = '',
                        projectName = '',
                        modulePaths = {},
                        classPaths = {},
                        javaExec = '',
                    })
                end)
            end
        end,
        on_exit = function() job = nil end,
    })
    vim.bo[buf].buflisted = false
    vim.cmd('normal! G') -- cursor on last line so the window follows the output
    vim.cmd('wincmd p') -- keep focus on the code window
    return true
end

--- Stop the Gradle process started by start() and close its terminal split.
function M.stop()
    if job then pcall(vim.fn.jobstop, job) job = nil end
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
    end
    term_buf = nil
end

return M
