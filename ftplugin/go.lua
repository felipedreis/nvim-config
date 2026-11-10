-- Debugging keymaps for Go (delve via nvim-dap-go); <leader>c/o/i/b/q are global in after/plugin/dap.lua
local opts = function(desc) return { buffer = true, desc = desc } end
vim.keymap.set('n', '<leader>x', function() require('dap').step_out() end, opts('DAP: step out'))
vim.keymap.set('n', '<leader>T', function() require('dap-go').debug_test() end, opts('Go: debug nearest test'))
vim.keymap.set('n', '<leader>C', function() require('dap-go').debug_last_test() end, opts('Go: debug last test'))
