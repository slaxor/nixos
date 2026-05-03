-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Define capabilities for completion, etc.
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.insertTextModeSupport = { valueSet = { 1, 2 } }
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.resolveSupport = {
  properties = { "documentation", "additionalTextEdits", "insertTextFormat", "insertTextMode", "command" }
}
capabilities.textDocument.completion.completionList.itemDefaults = { "commitCharacters", "editRange", "insertTextFormat",
  "insertTextMode", "data" }
capabilities.textDocument.completion.contextSupport = true
capabilities.textDocument.completion.dynamicRegistration = false
capabilities.textDocument.completion.insertTextMode = 1

local lsp_format = require("lsp-format")
lsp_format.setup({})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    lsp_format.on_attach(client, args.buf)
  end,
})

vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
-- vim.lsp.config('go', {setup = {capabilities = capabilities}})

vim.lsp.enable('go')
vim.lsp.config('go', {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})

vim.lsp.config('nixd', {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true })
  end,
  capabilities = capabilities,
})
vim.lsp.enable('nixd')

vim.lsp.config('pyright', { capabilities = capabilities })
vim.lsp.enable('pyright')

vim.lsp.config('bashls', { capabilities = capabilities })
vim.lsp.enable('bashls')

vim.lsp.enable('marksman')
vim.lsp.config('marksman', { capabilities = capabilities })

vim.lsp.config('rust_analyzer', { capabilities = capabilities })
vim.lsp.enable('rust_analyzer')

vim.lsp.config('jsonls', { capabilities = capabilities })
vim.lsp.enable('jsonls')

vim.lsp.config('lua-language-server', {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})
vim.lsp.enable('lua-language-server')

vim.lsp.config["tinymist"] = {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onType",
    semanticTokens = "disable"
  },
  capabilities = capabilities,
}
vim.lsp.enable('tinymist')

vim.lsp.config('efm', {
  init_options = { documentFormatting = true },
  settings = {
    rootMarkers = { ".git/" },
    -- languages = {
    -- lua = {
    -- {formatCommand = "lua-format -i", formatStdin = true}
    -- },
    -- sh = {
    -- {formatCommand = "shfmt -s", formatStdin = true}
    -- },
    -- json = {
    -- {formatCommand = "jq '.'", formatStdin = true}
    -- },
    -- yaml = {
    -- {formatCommand = "yq '.'", formatStdin = true}
    -- },
    -- },
  },
  capabilities = capabilities
})
vim.lsp.enable('efm')

-- vim.lsp.enable('rnix')
-- vim.lsp.config('rnix', {
--   cmd = { "rnix-lsp" },
--   filetypes = { "nix" },
--   init_options = {},
--   root_dir = '/nix',
--   settings = {},
-- })

-- vim.lsp.config.lsp_ai.setup({
--   init_options = {
--     memory = {
--       file_store = {}
--     },
--     models = {
--       model1 = {
--         type = "open_ai",
--         chat_endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
--         model = "gemini-1.5-flash", -- or "gemini-1.5-pro"
--         auth_token_env_var_name = "GEMINI_API_KEY",
--         parameters = {
--           max_tokens = 4096,
--           messages = {
--             { role = "system", content = "You are an intelligent coding assistant inside Neovim." }
--           }
--         }
--       }
--     },
--     chat = {
--       {
--         trigger = "@chat",
--         action_display_name = "Chat with Gemini",
--         model = "model1",
--         parameters = {
--           max_context = 4096,
--           max_tokens = 2048
--         }
--       }
--     },
--   },
-- })

-- vim.lsp.config.lsp_ai.setup({
-- init_options = {
-- memory = {
-- file_store = {}
-- },
-- models = {
-- model1 = {
-- type = "ollama",
-- model = "qwen2.5-coder:7b", -- CHANGE THIS if you pulled a different model
-- Optional: Force the endpoint if default fails (usually not needed)
-- chat_endpoint = "http://127.0.0.1:11434/api/chat",
-- parameters = {
-- temperature = 0.2, -- Lower is better for code accuracy
-- num_ctx = 8192     -- Context window size (increase if you have RAM)
-- }
-- }
-- },
-- chat = {
-- {
-- trigger = "@chat",
-- action_display_name = "Chat with Local AI",
-- model = "model1",
-- parameters = {
-- max_context = 4096,
-- max_tokens = 2048,
-- system = "You are an expert coding assistant. Provide concise, correct code."
-- }
-- }
-- },
-- },
-- })
