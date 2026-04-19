NVIM_CONFIG_DIR := $(HOME)/.config/nvim
PACKER_DIR      := $(HOME)/.local/share/nvim/site/pack/packer/start/packer.nvim

.PHONY: install packer

install: packer
	@mkdir -p $(NVIM_CONFIG_DIR)
	@cp -f init.lua $(NVIM_CONFIG_DIR)/init.lua
	@cp -rf lua        $(NVIM_CONFIG_DIR)/
	@cp -rf after      $(NVIM_CONFIG_DIR)/
	@cp -rf ftplugin   $(NVIM_CONFIG_DIR)/
	@echo "Config copied to $(NVIM_CONFIG_DIR)"
	@echo "Open nvim and run :PackerSync to install plugins, then :Mason to install LSP servers."

packer:
	@if [ ! -d "$(PACKER_DIR)" ]; then \
		echo "Installing Packer..."; \
		git clone --depth 1 https://github.com/wbthomason/packer.nvim $(PACKER_DIR); \
	fi
