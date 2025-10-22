-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--   capabilities = capabilities
-- }

vim.lsp.enable('pyright')
vim.lsp.config('pyright', {
  cmd = {'pyright'},
})

vim.lsp.enable('gopls')
vim.lsp.config('gopls', {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  capabilities = capabilities
})

vim.lsp.enable('rust-analyzer')
vim.lsp.config('rust-analyzer', {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      }
    }
  },
  capabilities = capabilities
})

-- vim.lsp.enable('rnix')
-- vim.lsp.config('rnix', {
--   cmd = { "rnix-lsp" },
--   filetypes = { "nix" },
--   init_options = {},
--   root_dir = '/nix',
--   settings = {},
-- })

vim.lsp.enable('bashls')
vim.lsp.config('bashls', {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)"
    },
  },
})

vim.lsp.enable('asm_lsp')
vim.lsp.enable('awk_ls') -- npm install -g awk-language-server
vim.lsp.enable('clangd')
vim.lsp.enable('css_variables') -- npm i -g css-variables-language-server
vim.lsp.enable('cssmodules_ls') -- npm install -g cssmodules-language-server
vim.lsp.enable('custom_elements_ls') -- npm install -g cssmodules-language-server
vim.lsp.enable('docker_compose_language_service') -- npm install @microsoft/compose-language-service
vim.lsp.enable('dockerls') -- npm install -g dockerfile-language-server-nodejs
vim.lsp.enable('html') -- npm i -g vscode-langservers-extracted
--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('html', {
  capabilities = capabilities,
  filetypes = { "html", "tmpl" },
})
vim.lsp.enable('jsonls') -- npm i -g vscode-langservers-extracted
vim.lsp.enable('lsp_ai')
vim.lsp.config('lsp_ai', {
  cmd = { "lsp-ai" },
  filetypes = {},
  init_options = {
    memory = {
      file_store = vim.empty_dict()
    },
    models = {
      model1 = {
        type =  "llama_cpp",
        repository = "stabilityai/stable-code-3b",
        name = "stable-code-3b-Q5_K_M.gguf",
        n_ctx = 2048,
        n_gpu_layers = 1000,
      },
      model2 = {
        type =  "ollama",
        model = "deepseek-coder",
      },
      model3 = {
        type = "open_ai",
        chat_endpoint = "https://api.groq.com/openai/v1/chat/completions",
        model = "llama3-70b-8192",
        auth_token_env_var_name = "GROQ_API_KEY",
      },
    }
  },
})

vim.lsp.enable('ltex_plus')

vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath('config')
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths
          -- here.
          -- '${3rd}/luv/library'
          -- '${3rd}/busted/library'
        }
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      }
    })
  end,
  settings = {
    Lua = {}
  }
})
vim.lsp.enable('pug') -- go install github.com/opa-oz/pug-lsp@latest

vim.lsp.enable('jqls') -- go install github.com/wader/jq-lsp@master

vim.lsp.enable('ruby_lsp')
vim.lsp.enable('standardrb')

vim.lsp.enable('sqls') -- go install github.com/sqls-server/sqls@latest

vim.lsp.config('ts_ls', {
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
        languages = {"javascript", "typescript", "vue"},
      },
    },
  },
  filetypes = {
    "javascript",
    "typescript",
    "vue",
  },
})

vim.lsp.enable('vimls') -- npm install -g vim-language-server

-- vim.lsp.enable('ts_ls') -- npm install -g typescript typescript-language-server
-- or
-- vim.lsp.enable('volar') -- npm install -g @vue/language-server

vim.lsp.enable('wasm_language_tools') -- cargo install wat_server

vim.lsp.enable('slint') -- cargo install slint-lsp
vim.lsp.config('slint', {
  cmd = { "slint-lsp" },
  filetypes = { "slint" },
})
-- You must make sure volar is setup
-- e.g. vim.lsp.config('volar')
-- See volar's section for more information
-- local on_attach_vim = function()
--   document_highlight()
--   protocol.CompletionItemKind = {
--     '';             -- Text          = 1;
--     'ƒ';             -- Method        = 2;
--     'ƒ';             -- Function      = 3;
--     '';             -- Constructor   = 4;
--     '識';            -- Field         = 5;
--     '𝑋';             -- Variable      = 6;
--     '';             -- Class         = 7;
--     '';             -- Interface     = 8;
--     '';             -- Module        = 9;
--     'Property';      -- Property      = 10;
--     'Unit';          -- Unit          = 11;
--     'Value';         -- Value         = 12;
--     '了';            -- Enum          = 13;
--     '';             -- Keyword       = 14;
--     '﬌';             -- Snippet       = 15;
--     'Color';         -- Color         = 16;
--     '';             -- File          = 17;
--     'Reference';     -- Reference     = 18;
--     '';             -- Folder        = 19;
--     '';             -- EnumMember    = 20;
--     '';             -- Constant      = 21;
--     '';             -- Struct        = 22;
--     'Event';         -- Event         = 23;
--     'Operator';      -- Operator      = 24;
--     'TypeParameter'; -- TypeParameter = 25;
--   }
-- end
