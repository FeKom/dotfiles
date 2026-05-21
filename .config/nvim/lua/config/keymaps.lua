-- Keymaps customizados
local map = vim.keymap.set

-- ╭──────────────────────────────────────────╮
-- │            Salvar / Fechar                │
-- ╰──────────────────────────────────────────╯
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Salvar arquivo" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Salvar arquivo no insert" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Fechar janela" })

-- ╭──────────────────────────────────────────╮
-- │       Navegação de linhas (Ctrl+P/N)      │
-- ╰──────────────────────────────────────────╯
-- Ctrl+P → linha de cima | Ctrl+N → linha de baixo
map({ "n", "v" }, "<C-p>", "k", { desc = "Linha anterior" })
map({ "n", "v" }, "<C-n>", "j", { desc = "Próxima linha" })
map("i", "<C-p>", "<Up>", { desc = "Linha anterior" })
map("i", "<C-n>", "<Down>", { desc = "Próxima linha" })

-- ╭──────────────────────────────────────────╮
-- │    Navegação de palavras (Ctrl+Shift)     │
-- ╰──────────────────────────────────────────╯
-- Ctrl+Shift+P → início da próxima palavra
-- Ctrl+Shift+N → início da palavra anterior
map({ "n", "v" }, "<C-S-p>", "w", { desc = "Início da próxima palavra" })
map({ "n", "v" }, "<C-S-n>", "b", { desc = "Início da palavra anterior" })
map("i", "<C-S-p>", "<C-o>w", { desc = "Início da próxima palavra" })
map("i", "<C-S-n>", "<C-o>b", { desc = "Início da palavra anterior" })

-- ╭──────────────────────────────────────────╮
-- │       Busca de arquivo (Ctrl+Shift+F)     │
-- ╰──────────────────────────────────────────╯
map("n", "<C-S-f>", "<leader>ff", { desc = "Buscar arquivo", remap = true })

-- ╭──────────────────────────────────────────╮
-- │              Explorer (Ctrl+E)            │
-- ╰──────────────────────────────────────────╯
map("n", "<C-e>", function() Snacks.explorer() end, { desc = "Toggle Explorer com foco" })

-- ╭──────────────────────────────────────────╮
-- │       Abas com Ctrl+<dígito>              │
-- ╰──────────────────────────────────────────╯
for i = 1, 9 do
  map("n", "<C-" .. i .. ">", "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Ir para aba " .. i })
end

-- ╭──────────────────────────────────────────╮
-- │       Duplicar linha (Ctrl+Shift+D)       │
-- ╰──────────────────────────────────────────╯
map("n", "<C-S-d>", "<cmd>t.<CR>", { desc = "Duplicar linha abaixo" })
map("v", "<C-S-d>", ":'<,'>t'><CR>gv", { desc = "Duplicar seleção abaixo" })
map("i", "<C-S-d>", "<Esc><cmd>t.<CR>gi", { desc = "Duplicar linha abaixo" })

-- ╭──────────────────────────────────────────╮
-- │         Terminal (estilo VSCode)          │
-- ╰──────────────────────────────────────────╯
-- Ctrl+`  → terminal flutuante (toggle)
map({ "n", "t" }, "<C-`>", function()
  Snacks.terminal.toggle(nil, { win = { position = "float" } })
end, { desc = "Terminal flutuante" })

-- Cmd+`  → terminal horizontal embaixo (toggle)
map({ "n", "t" }, "<D-`>", function()
  Snacks.terminal.toggle(nil, {
    win = { position = "bottom", height = 0.3 },
  })
end, { desc = "Terminal horizontal" })

-- ╭──────────────────────────────────────────╮
-- │             Claude Code (Ctrl+,)          │
-- ╰──────────────────────────────────────────╯
map({ "n", "t" }, "<C-,>", function()
  Snacks.terminal.toggle("claude", {
    win = { position = "float", width = 0.85, height = 0.85 },
    env = { TERM = "xterm-256color" },
  })
end, { desc = "Claude Code" })
-- Mantém leader+ai também como alternativa
map({ "n", "t" }, "<leader>ai", function()
  Snacks.terminal.toggle("claude", {
    win = { position = "float", width = 0.85, height = 0.85 },
    env = { TERM = "xterm-256color" },
  })
end, { desc = "Claude Code" })

-- ╭──────────────────────────────────────────╮
-- │       Mover linhas (Alt+j/k)              │
-- ╰──────────────────────────────────────────╯
-- Alt+j/k para mover já vem pelo mini-move extra
-- Shift+Alt+j/k para duplicar (mantido como alternativa)
map("n", "<S-A-j>", "<cmd>t.<CR>", { desc = "Duplicar linha abaixo" })
map("n", "<S-A-k>", "<cmd>t.-1<CR>", { desc = "Duplicar linha acima" })
map("v", "<S-A-j>", ":'<,'>t'><CR>gv", { desc = "Duplicar seleção abaixo" })
map("v", "<S-A-k>", ":'<,'>t'<-1<CR>gv", { desc = "Duplicar seleção acima" })

-- ╭──────────────────────────────────────────╮
-- │          Indent com seleção               │
-- ╰──────────────────────────────────────────╯
map("v", "<", "<gv", { desc = "Dedent e manter seleção" })
map("v", ">", ">gv", { desc = "Indent e manter seleção" })
map("v", "<Tab>", ">gv", { desc = "Indent com Tab" })
map("v", "<S-Tab>", "<gv", { desc = "Dedent com Shift+Tab" })

-- ╭──────────────────────────────────────────╮
-- │       Atalhos VSCode-like                 │
-- ╰──────────────────────────────────────────╯
map("n", "<C-a>", "ggVG", { desc = "Selecionar tudo" })
map("n", "<C-z>", "u", { desc = "Desfazer" })
map("n", "<C-y>", "<C-r>", { desc = "Refazer" })
map("i", "<C-z>", "<Esc>ui", { desc = "Desfazer no insert" })

-- ╭──────────────────────────────────────────╮
-- │        Navegação rápida                   │
-- ╰──────────────────────────────────────────╯
-- Voltar / Avançar no histórico de posições (como Alt+←/→ no VSCode)
map("n", "<A-Left>", "<C-o>", { desc = "Voltar posição anterior" })
map("n", "<A-Right>", "<C-i>", { desc = "Avançar posição" })

-- Ir para definição / referências (LSP)
map("n", "gd", vim.lsp.buf.definition, { desc = "Ir para definição" })
map("n", "<A-CR>", vim.lsp.buf.definition, { desc = "Ir para definição (Option+Enter)" })
map("n", "gr", vim.lsp.buf.references, { desc = "Ver referências" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover info" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename símbolo" })

-- ╭──────────────────────────────────────────╮
-- │            Splits / Janelas               │
-- ╰──────────────────────────────────────────╯
map("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Split à direita (VSCode)" })
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sc", "<cmd>close<CR>", { desc = "Fechar split" })
-- Redimensionar splits
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Aumentar split horizontal" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Diminuir split horizontal" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Aumentar split vertical" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Diminuir split vertical" })

-- ╭──────────────────────────────────────────╮
-- │            Buffers rápido                 │
-- ╰──────────────────────────────────────────╯
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Salvar" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Sair" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Fechar buffer" })

-- ╭──────────────────────────────────────────╮
-- │        Qualidade de vida                  │
-- ╰──────────────────────────────────────────╯
-- Limpar highlight de busca com Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Limpar busca" })

-- Não copiar ao deletar com x
map("n", "x", '"_x', { desc = "Delete sem copiar" })

-- Colar sem perder o registro em visual mode
map("v", "p", '"_dP', { desc = "Colar sem perder clipboard" })

-- Manter cursor centrado ao navegar
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centrado" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centrado" })
map("n", "n", "nzzzv", { desc = "Próximo match centrado" })
map("n", "N", "Nzzzv", { desc = "Match anterior centrado" })
