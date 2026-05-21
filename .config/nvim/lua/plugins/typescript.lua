return {
  -- Disable tsgo (experimental, poor import support) and ts_ls (legacy)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = { enabled = false },
      },
    },
  },

  -- vtsls: VS Code TypeScript extension as LSP — best import resolution
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.vtsls = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
          },
        },
      }
    end,
  },
}
