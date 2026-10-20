vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Focus the tree; if already in the tree, jump back to the previous window
vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "NvimTree" then
    vim.cmd("wincmd p")
  else
    vim.cmd("NvimTreeFocus")
  end
end, { desc = "Focus file tree / return to editor" })
