-- Python enhancements for LazyVim
return {
  -- 🐍 Virtual Environment Selector - Easy venv switching with <leader>cv
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
      "nvim-telescope/telescope.nvim",
    },
    branch = "regexp",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    ft = "python",
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
      { "<leader>cV", "<cmd>VenvSelectCached<cr>", desc = "Select VirtualEnv (cached)", ft = "python" },
    },
  },

  -- 🔧 Enhanced Pyright configuration with auto venv detection
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          enabled = true,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic", -- or "strict" for stricter checks
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                autoImportCompletions = true,
              },
            },
          },
        },
      },
    },
  },

  -- 🐛 Better Python debugging support
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- Auto-detect python path from venv
      local function get_python_path()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          return cwd .. "/venv/bin/python"
        else
          return "python3"
        end
      end

      require("dap-python").setup(get_python_path())

      -- Add test runners
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " +")
        end,
      })
    end,
    keys = {
      {
        "<leader>dPt",
        function()
          require("dap-python").test_method()
        end,
        desc = "Debug Method",
        ft = "python",
      },
      {
        "<leader>dPc",
        function()
          require("dap-python").test_class()
        end,
        desc = "Debug Class",
        ft = "python",
      },
    },
  },

  -- 📦 Mason: Ensure Python tools are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright", -- LSP
        "debugpy", -- Python debugger
        "black", -- Code formatter
        "isort", -- Import sorter
        "mypy", -- Static type checker (optional)
      },
    },
  },

  -- ⚡ Neotest: Better test runner UI
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          dap = { justMyCode = false },
          args = { "--log-level", "DEBUG" },
          runner = "pytest",
          -- Auto-detect venv python
          python = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
              return cwd .. "/.venv/bin/python"
            elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
              return cwd .. "/venv/bin/python"
            end
            return "python3"
          end,
        },
      },
    },
  },

  -- 🎨 Auto-formatting with conform.nvim
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "black", "isort" },
      },
    },
  },

  -- 🔍 Linting with nvim-lint
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "mypy" },
      },
    },
  },
}
