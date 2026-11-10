require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
    preserve_window_proportions = true, -- don't equalize other windows when the tree changes
  },
  actions = {
    open_file = {
      resize_window = false, -- keep the width I dragged the tree to
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Focus the tree; if already in the tree, jump back to the previous window
vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "NvimTree" then
    vim.cmd("wincmd p")
  else
    vim.cmd("NvimTreeFocus")
  end
end, { desc = "Focus file tree / return to editor" })
