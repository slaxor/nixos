{ lib, pkgs, ... }:
let
  nixvim = builtins.getFlake "github:nix-community/nixvim/e9fbbd56eab78751ba4c166c31a1667042528ced";
  nvim-spell-de-utf8-dictionary = builtins.fetchurl {
    url = "https://ftp.pl.vim.org/pub/vim/runtime/spell/de.utf-8.spl";
    sha256 = "sha256:1ld3hgv1kpdrl4fjc1wwxgk4v74k8lmbkpi1x7dnr19rldz11ivk";
  };
  nvim-spell-de-utf8-suggestions = builtins.fetchurl {
    url = "https://ftp.pl.vim.org/pub/vim/runtime/spell/de.utf-8.sug";
    sha256 = "sha256:0j592ibsias7prm1r3dsz7la04ss5bmsba6l1kv9xn3353wyrl0k";
  };
  nvim-spell-en-utf8-dictionary = builtins.fetchurl {
    url = "https://ftp.pl.vim.org/pub/vim/runtime/spell/en.utf-8.spl";
    sha256 = "sha256:0w1h9lw2c52is553r8yh5qzyc9dbbraa57w9q0r9v8xn974vvjpy";
  };
  nvim-spell-en-utf8-suggestions = builtins.fetchurl {
    url = "https://ftp.pl.vim.org/pub/vim/runtime/spell/en.utf-8.sug";
    sha256 = "sha256:1v1jr4rsjaxaq8bmvi92c93p4b14x2y1z95zl7bjybaqcmhmwvjv";
  };
  insert-abbrevs = {
    "teh" = "the";
    "recieve" = "receive";
    "mfg" = "Mit freundlichen Grüßen";
    "8<" = "-----------8<-----------8<-----------8<-----------";
    ">8" = "----------->8----------->8----------->8-----------";
    "..." = "…";
    "retrun" = "return";
    "retunr" = "return";
  };

  abolishes = [
    "{despa,sepa}rat{e,es,ed,ing} {despe,sepa}rat{}"
    "anomol{y,ies} anomal{}"
  ];
in
{
  imports = [ nixvim.homeModules.nixvim ];
  # home.packages = with pkgs; [
  # ];
  programs.nixvim = {
    enable = true;
    nixpkgs.pkgs = pkgs;
    colorschemes.habamax.enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    diagnostic.settings = {
      virtual_text = true;
      severity_sort = true;
    };
    # vim.keymap.setr"n", ">;", "<Plug>Argumentative_MoveRight", {})
    # vim.keymap.set("n", "[;", "<Plug>Argumentative_Prev", {})
    # vim.keymap.set("n", "];", "<Plug>Argumentative_Next", {})
    # vim.keymap.set("o", "a;", "<Plug>Argumentative_OpPendingOuterTextObject", {})
    # vim.keymap.set("o", "i;", "<Plug>Argumentative_OpPendingInnerTextObject", {})
    # vim.keymap.set("v", "<m-Down>", ":m'>+1<CR>gv", { silent = true })
    # vim.keymap.set("v", "<m-Up>", ":m'<-2<CR>gv", { })
    # vim.keymap.set("x", "[;", "<Plug>Argumentative_XPrev", {})
    # vim.keymap.set("x", "];", "<Plug>Argumentative_XNext", {})
    # vim.keymap.set("x", "a;", "<Plug>Argumentative_OuterTextObject", {})
    # vim.keymap.set("x", "i;", "<Plug>Argumentative_InnerTextObject", {})
    # vim.keymap.set("i", "<leader>p", InsertPassword, { noremap = true, silent = true })
    # vim.keymap.set("n", "<leader>p", InsertPassword, { noremap = true, silent = true })
    # vim.cmd("abbr 8< -----------8<-----------8<-----------8<-----------")
    # vim.cmd("abbr >8 ----------->8----------->8----------->8-----------")
    # vim.cmd("abbr \\...  …")
    # vim.cmd("abbr retrun return")
    # vim.cmd("abbr retunr return")

    keymaps =
      lib.mapAttrsToList (lhs: rhs: {
        mode = "ia";
        key = lhs;
        action = rhs;
      }) insert-abbrevs
      ++ [
        {
          mode = [
            "i"
            "n"
          ];
          key = "<leader>p";
          action = "<cmd>lua InsertPassword()<cr>";
          options = {
            silent = true;
            desc = "insert a random string";
          };
        }
        {
          mode = "n";
          key = "<leader>c";
          action = "/<<<<<<< \\_.\\{-}=======\\_.\\{-}>>>>>>>.*/<CR>";
          options.desc = "show git conflicts";
        }
        {
          mode = "n";
          key = "<leader>sd";
          action = ":w !diff -y --ignore-all-space --suppress-common-lines % -<CR>";
          options.desc = "show unsaved";
        }
        {
          mode = "n";
          key = "<c-down>";
          action = "]egv";
          options.desc = "";
        }
        {
          mode = "n";
          key = "<c-up>";
          action = "[egv";
          options.desc = "";
        }
        {
          mode = "n";
          key = "=";
          action = "toggle_word";
          options.desc = "toggle booleans";
        }
        {
          mode = "n";
          key = "<A-f>";
          # action = "<cmd>Lf<cr>";
          action = "<cmd>Yazi cwd<cr>";
          options.desc = "file browser";
        }
        {
          mode = [
            "i"
            "n"
            "v"
          ];
          key = "<A-c>";
          action.__raw = ''require("slaxor.keymaps").comment_toggle'';
          options.desc = "toggle comment and move down";
        }
        {
          mode = "n";
          key = "<A-S-w>";
          action = ":bd!<cr>";
          options.desc = "force delete buffer";
        }
        {
          mode = "n";
          key = "<A-w>";
          action = ":bd<cr>";
          options.desc = "delete buffer";
        }
        {
          mode = "n";
          key = "<A-Left>";
          action = ":bp<cr>";
          options.desc = "buffer previous";
        }
        {
          mode = "n";
          key = "<A-Right>";
          action = ":bn<cr>";
          options.desc = "buffer next";
        }
        {
          mode = "n";
          key = "<A-Up>";
          action = "<cmd>m .-2<cr>==";
          options = {
            silent = true;
            desc = "move line up";
          };
        }
        {
          mode = "n";
          key = "<A-Down>";
          action = "<cmd>m .+1<cr>==";
          options = {
            silent = true;
            desc = "move line down";
          };
        }
        {
          mode = "v";
          key = "<A-Up>";
          action = ":m '<-2<cr>gv=gv";
          options.desc = "move text up";
        }
        {
          mode = "v";
          key = "<A-Down>";
          action = ":m '>+1<cr>gv=gv";
          options.desc = "move text down";
        }
        {
          mode = [
            "i"
            "s"
          ];
          key = "<Tab>";
          action.__raw = ''require("slaxor.keymaps").tab_expand'';
          options.desc = "snippet expand/jump or tab";
        }
        {
          mode = [
            "i"
            "s"
          ];
          key = "<S-Tab>";
          action.__raw = ''require("slaxor.keymaps").tab_jump_back'';
          options.desc = "snippet jump back or shift-tab";
        }
      ];

    globals = {
      mapleader = ",";
    };

    opts = {
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
    };

    plugins = {
      barbar.enable = true;
      abolish.enable = true;
      bacon = {
        enable = true;
        settings = {
          quickfix = {
            enabled = false;
            event_trigger = true;
          };
        };
      };
      blink-ripgrep.enable = true;
      bufdelete.enable = true;
      ccc.enable = true;
      commentary.enable = true;
      comment = {
        enable = true;
        settings.pre_hook = ''
          require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
        '';
      };
      dap.enable = true;
      dap-disasm.enable = true;
      dap-go.enable = true;
      dap-lldb.enable = true;
      dap-python.enable = true;
      dap-rr.enable = true;
      dap-ui.enable = true;
      dap-view.enable = true;
      debugprint.enable = true;
      devdocs.enable = true;
      # diagram.enable = true;
      diffview.enable = true;
      direnv.enable = true;
      emmet.enable = true;
      fzf-lua.enable = true;
      glow.enable = true;
      helm.enable = true;
      hex.enable = true;
      just.enable = true;
      vim-css-color.enable = true;
      typst-preview.enable = true;
      yazi.enable = true;
      cmp = {
        enable = true;
        settings = {
          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<CR>" = "cmp.mapping.confirm({ select = false })";
            "<C-e>" = "cmp.mapping.abort()";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          };
          snippet.expand = ''function(args) require("luasnip").lsp_expand(args.body) end'';
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
          ];
        };
      };
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 1000;
            lsp_format = "fallback";
          };
          formatters_by_ft = {
            go = [
              "gofumpt"
              "goimports"
            ];
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            sh = [ "shfmt" ];
            just = [ "just" ]; # just --fmt
            typst = [ "typstyle" ];
          };
          extraPackages = with pkgs; [
            gofumpt
            gotools
            nixfmt
            shfmt
            stylua
          ];
        };
      };
      dap-virtual-text.enable = true;
      fidget.enable = true;
      lf.enable = true;
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          gopls.enable = true;
          nil_ls = {
            enable = true;
            autoEvalInputs = true;
            settings = {
              nix.flake.autoArchive = true;
              formatting.command = [ (lib.getExe pkgs.nixfmt) ];
            };
          };
          pyright.enable = true;
          lua_ls = {
            enable = true;
            settings = {
              runtime.version = "LuaJIT";
              diagnostics.globals = [ "vim" ];
              workspace = {
                checkThirdParty = false;
                library.__raw = ''vim.api.nvim_get_runtime_file("", true)'';
              };
            };
          };
          yamlls.enable = true;
          marksman.enable = true;
          helm_ls.enable = true;
          efm.enable = true;
        };
        keymaps.lspBuf = {
          gd = "definition";
          gD = "declaration";
        };
      };
      lualine.enable = true;
      luasnip = {
        enable = true;
        fromSnipmate = [ { paths = ./nvim/snippets; } ];
      };
      markdown-preview.enable = true;
      # origami.enable = true;
      otter.enable = true;
      toggleterm.enable = true;
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          awk
          bash
          c
          caddy
          cmake
          comment
          css
          csv
          desktop
          devicetree
          diff
          disassembly
          git_config
          gitattributes
          gitcommit
          gitignore
          gnuplot
          go
          gomod
          gosum
          gotmpl
          gowork
          gpg
          helm
          html
          http
          ini
          javascript
          jq
          json
          just
          llvm
          lua
          luadoc
          make
          markdown
          markdown_inline
          mermaid
          muttrc
          nasm
          nix
          nix
          objdump
          passwd
          pem
          printf
          pug
          readline
          regex
          ruby
          rust
          slint
          sql
          ssh_config
          starlark
          strace
          sway
          terraform
          tmux
          toml
          typescript
          typst
          udev
          vim
          vimdoc
          yaml
        ];
      };
      ts-context-commentstring = {
        enable = true;
        settings.enable_autocmd = false;
      };
      typst-vim.enable = true;
      web-devicons.enable = true;
      qmk-nvim.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      SudoEdit-vim
      file-line
      vim-visual-increment
      qmk-nvim
    ];

    extraConfigLua = ''
      require("slaxor")
      vim.filetype.add({
        pattern = {
          ["%.yaml%.tmpl$"]  = "yaml.gotexttmpl",
          ["%.json%.tmpl$"]  = "json.gotexttmpl",
          [".*/kube/config"] = "yaml",
          [".*kubeconfig"]   = "yaml",
        },
       })
       vim.api.nvim_create_autocmd("VimEnter", {
         once = true,
         callback = function()
           ${lib.concatMapStrings (a: "vim.cmd [[Abolish ${a}]]") abolishes}
         end,
       })
       vim.g.skip_ts_context_commentstring_module = true   -- speeds startup, skips legacy init'';

    extraFiles = {
      "after".source = ./nvim/after;
      "ftplugin".source = ./nvim/ftplugin;
      "lua/slaxor".source = ./nvim/lua/slaxor;
      "spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
      "spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
      "spell/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
      "spell/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
      "snippets".source = ./nvim/snippets;
    };
  };
}
