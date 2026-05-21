-- LazyVim extras habilitados
-- Cada import ativa LSP, treesitter, formatters e linters para a linguagem
return {
  -- === Linguagens ===
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  { import = "lazyvim.plugins.extras.lang.java" },
  { import = "lazyvim.plugins.extras.lang.elixir" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.lang.toml" },
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.markdown" },
  { import = "lazyvim.plugins.extras.lang.sql" },
  { import = "lazyvim.plugins.extras.lang.git" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },

  -- === Formatting & Linting ===
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.linting.eslint" },

  -- === Coding ===
  { import = "lazyvim.plugins.extras.coding.mini-surround" }, -- sa/sd/sr para surround
  { import = "lazyvim.plugins.extras.coding.yanky" },         -- clipboard ring com <leader>p

  -- === Editor ===
  { import = "lazyvim.plugins.extras.editor.illuminate" },  -- highlight palavra sob cursor
  { import = "lazyvim.plugins.extras.editor.inc-rename" },  -- rename incremental com preview
  { import = "lazyvim.plugins.extras.editor.mini-move" },   -- mover linhas/blocos com Alt+hjkl

  -- === UI ===
  { import = "lazyvim.plugins.extras.ui.treesitter-context" }, -- mostra contexto da função no topo
  { import = "lazyvim.plugins.extras.ui.indent-blankline" },   -- guias de indentação

  -- === Debug & Test ===
  { import = "lazyvim.plugins.extras.dap.core" },  -- debug adapter protocol
  { import = "lazyvim.plugins.extras.test.core" },  -- test runner (neotest)
}
