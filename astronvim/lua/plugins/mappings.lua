return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          [".b"] = {
            function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
            desc = "previous buffer",
          },
          [",b"] = {
            function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
            desc = "next buffer",
          },
          ["<leader>tt"] = {
            function() require("toggleterm").toggle(vim.v.count) end,
            desc = "toggle term",
          },
          ["<CR>"] = {
            function() require("flash").jump() end,
            desc = "Flash",
          },
        },
        t = {
          ["<Esc>"] = { "<C-\\><C-n>", desc = "escape terminal" },
        },
      },
    },
  },
}
