vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

function SetSpacing(spacing)
    spacing = spacing or 4
    vim.opt.tabstop = spacing
    vim.opt.softtabstop = spacing
    vim.opt.shiftwidth = spacing
    vim.opt.expandtab = true
end

SetSpacing()

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
