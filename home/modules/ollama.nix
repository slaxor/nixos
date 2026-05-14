{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ollama-rocm
  ];

  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_MODELS = "/dumpyard/ollama-models";
    };
  };

  # Optional: Auto-pull models when the service starts
  # This mimics the 'loadModels' feature from NixOS
  systemd.user.services.ollama = {
    Service = {
      ExecStartPost =
        let
          script = pkgs.writeShellScript "pull-models" ''
            until ${pkgs.curl}/bin/curl -s http://127.0.0.1:11434/api/tags > /dev/null; do
              echo "Waiting for Ollama..."
              sleep 2
            done
            MODELS=("qwen2.5-coder:7b" "mistral")
            for model in "''${MODELS[@]}"; do
              if ! ${config.services.ollama.package}/bin/ollama list | grep -q "$model"; then
                echo "Pulling $model..."
                ${config.services.ollama.package}/bin/ollama pull "$model"
              fi
            done
          '';
        in
        [ "${script}" ];
    };
  };

  programs.neovim.extraLuaConfig = /* lua */ ''
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    -- lspconfig.lsp_ai.setup({
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

    lspconfig.lsp_ai.setup({
      init_options = {
        memory = {
          file_store = {}
        },
        models = {
          model1 = {
            type = "ollama",
            model = "qwen2.5-coder:7b", -- CHANGE THIS if you pulled a different model
            -- Optional: Force the endpoint if default fails (usually not needed)
            -- chat_endpoint = "http://127.0.0.1:11434/api/chat",
            parameters = {
              temperature = 0.2, -- Lower is better for code accuracy
              num_ctx = 8192     -- Context window size (increase if you have RAM)
            }
          }
        },
        chat = {
          {
            trigger = "@chat",
            action_display_name = "Chat with Local AI",
            model = "model1",
            parameters = {
              max_context = 4096,
              max_tokens = 2048,
              system = "You are an expert coding assistant. Provide concise, correct code."
            }
          }
        },
      },
    })
  '';
}
