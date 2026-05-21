-- Zig language support for LazyVim
return {
  -- Treesitter: syntax highlighting + textobjects for Zig
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "zig" },
    },
  },

  -- NOTE: zls is NOT installed via Mason — Mason only ships the stable release
  -- and will break with Zig nightly (0.15.x). Build from source instead:
  --   git clone https://github.com/zigtools/zls ~/.local/zls
  --   cd ~/.local/zls && zig build -Doptimize=ReleaseSafe
  --   ln -s ~/.local/zls/zig-out/bin/zls /usr/local/bin/zls

  -- LSP: configure zls (resolved from PATH, not Mason)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zls = {
          enabled = true,
          -- Use the manually installed binary; falls back to PATH lookup
          cmd = { vim.fn.exepath("zls") ~= "" and vim.fn.exepath("zls") or "zls" },
          settings = {
            zls = {
              enable_inlay_hints = true,
              enable_snippets = true,
              warn_style = true,
              highlight_global_var_declarations = true,
            },
          },
        },
      },
    },
  },

  -- Formatting: zig fmt via conform.nvim
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        zig = { "zigfmt" },
      },
      formatters = {
        -- zig fmt is invoked as `zig fmt --stdin`
        zigfmt = {
          command = "zig",
          args = { "fmt", "--stdin" },
          stdin = true,
        },
      },
    },
  },

  -- Keymaps: build / run / test shortcuts (only active in .zig buffers)
  {
    "nvim-lua/plenary.nvim", -- already a dep of LazyVim, used for terminal util
    lazy = true,
  },
  {
    -- Use LazyVim's which-key to register Zig build keymaps
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>z", group = "Zig", icon = "⚡", ft = "zig" },
      },
    },
  },
  {
    -- Attach Zig-specific keymaps when opening a .zig file
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "zig",
        callback = function(ev)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
          end

          -- Build
          map("<leader>zb", "<cmd>!zig build<CR>",              "Zig build")
          -- Build & run (default exe step)
          map("<leader>zr", "<cmd>!zig build run<CR>",          "Zig build run")
          -- Run current file directly
          map("<leader>zf", function()
            vim.cmd("!" .. "zig run " .. vim.fn.expand("%"))
          end,                                                   "Zig run file")
          -- Test
          map("<leader>zt", "<cmd>!zig build test<CR>",         "Zig build test")
          -- Test current file only
          map("<leader>zT", function()
            vim.cmd("!" .. "zig test " .. vim.fn.expand("%"))
          end,                                                   "Zig test file")
          -- Format current file
          map("<leader>zF", function()
            vim.cmd("!" .. "zig fmt " .. vim.fn.expand("%"))
            vim.cmd("e")  -- reload buffer after fmt
          end,                                                   "Zig fmt file")
        end,
      })
    end,
  },
}
