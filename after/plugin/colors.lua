function ColorMyPencils() 
  color = color or "everforest"
  vim.cmd.colorscheme(color)
  vim.o.background = 'light'
end

ColorMyPencils()
