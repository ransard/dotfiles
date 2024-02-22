return {
  plugins = {
    { "akinsho/toggleterm.nvim", opts = { direction = "horizontal" } },
    { "AstroNvim/astrocommunity", {
          { import = "astrocommunity.colorscheme.nord-nvim" }
    }},
    {
      "nvim-telescope/telescope.nvim",
      opts = { defaults = { file_ignore_patterns = { "node_modules/*", "build/*", "*.svg" } } },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = "svelte",
        highlight = { enable = true}
      }
    }
  },
  mappings = {
    n = {
      [".b"] = {
        function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
        desc = "previous buffer",
      },
      [",b"] = {
        function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
        desc = "next buffer",
      },
      ["<leader>tt"] = { function() require("toggleterm").toggle(vim.v.count) end, desc = "toggle term" },
    },
    t = {
      ["<Esc>"] = { "<C-\\><C-n>", desc = "escape terminal" },
    },
  },
  colorscheme = "nord"
}
