return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        theme = "lotus", -- lotus is the light variant
        background = {
          dark = "wave",
          light = "lotus",
        },
      })
      vim.o.background = "dark"
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
