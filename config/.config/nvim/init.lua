-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Plugins
require("lazy").setup({
  -- Tmux navigation (Ctrl-h/j/k/l to move between tmux panes and nvim splits)
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- LSP config (uses the nvim 0.11+ vim.lsp.config / vim.lsp.enable API;
  -- nvim-lspconfig is kept only for its bundled default server configs).
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Terraform LSP
      vim.lsp.config("terraformls", {})
      vim.lsp.enable("terraformls")

      -- Format on save for Terraform files
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.tf", "*.tfvars" },
        callback = function()
          vim.lsp.buf.format()
        end,
      })

      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })
    end,
  },

  -- Terraform syntax highlighting
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "tf", "hcl" },
  },

  -- Treesitter for better syntax highlighting
  -- Pinned to `master`: the `main` branch is the v1.0 rewrite which removed
  -- the classic `nvim-treesitter.configs` API used below.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "terraform", "hcl" },
        highlight = { enable = true },
      })
    end,
  },
})
