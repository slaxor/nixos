{ pkgs, config, ... }:
let
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
    url = "https://ftp.pl.vim.org/pub/vim/runtime/spell/en.utf-8.spl";
    sha256 = "sha256:0w1h9lw2c52is553r8yh5qzyc9dbbraa57w9q0r9v8xn974vvjpy";
  };
in
{
  home.packages = with pkgs; [
    # diagnostic-languageserver
    asm-lsp
    awk-language-server
    bash-language-server
    ccls
    cmake-language-server
    docker-language-server
    dts-lsp
    efm-langserver
    gopls
    helm-ls
    javascript-typescript-langserver
    jq-lsp
    just-lsp
    # kcl-language-server
    lemminx
    lua
    lua-language-server
    marksman
    mpls
    nginx-language-server
    nil
    postgres-language-server
    protols
    pyright
    sqls
    starlark
    starpls
    systemd-language-server
    ty
    vim-language-server
    vscode-langservers-extracted
    write-good
    yaml-language-server
    yamllint
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      vimPlugins.nvim-dap-virtual-text
      tree-sitter
    ];
    plugins = with pkgs.vimPlugins; [
      (pkgs.vimUtils.buildVimPlugin {
        name = "guihua";
        src = pkgs.fetchFromGitHub {
          owner = "ray-x";
          repo = "guihua.lua";
          rev = "ef44ba40f12e56c1c9fa45967f2b4d142e4b97a0";
          hash = "sha256-9iFqh12orsGnQniDloO+aXoBYuTqOW4pGHi3LBB2m4Q=";
        };
        doCheck = false;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "d2-vim";
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "terrastruct";
          repo = "d2-vim";
          rev = "cb3eb7fcb1a2d45c4304bf2e91077d787b724a39";
          sha256 = "sha256-HmDQfOIoSV93wqRe7O4FPuHEmAxwoP1+Ut+sKhB62jA=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "tree-sitter-d2";
        version = "0.7.2";
        src = pkgs.fetchFromGitHub {
          owner = "ravsii";
          repo = "tree-sitter-d2";
          rev = "d552b17bf3e4c29b3f090a4a02f61ed2c4a67b3b"; # v0.7.2
          sha256 = "sha256-zx6ud3uh+0Z+cYdP2KkFA27Kb6fW/CSGpC1C4YmCIo0=";
        };
      })
      SudoEdit-vim
      barbar-nvim
      cmp-nvim-lsp
      efmls-configs-nvim
      fidget-nvim
      file-line
      friendly-snippets
      fzf-lsp-nvim
      go-nvim
      lsp-format-nvim
      luasnip
      markdown-nvim
      markdown-preview-nvim
      nerdcommenter
      nvim-cmp
      nvim-dap
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-lspconfig
      nvim-web-devicons
      (nvim-treesitter.withPlugins (p: [
        p.awk
        p.bash
        p.c
        p.caddy
        p.cmake
        p.css
        p.csv
        p.desktop
        p.devicetree
        p.diff
        p.disassembly
        p.git_config
        p.gitattributes
        p.gitcommit
        p.gitignore
        p.gnuplot
        p.go
        p.gomod
        p.gowork
        p.gotmpl
        p.comment
        p.gosum
        p.gpg
        p.helm
        p.html
        p.http
        p.ini
        p.javascript
        p.jq
        p.json
        p.jsonc
        p.just
        p.llvm
        p.lua
        p.lua
        p.luadoc
        p.make
        p.markdown
        p.markdown_inline
        p.mermaid
        p.muttrc
        p.nasm
        p.nix
        p.objdump
        p.passwd
        p.pem
        p.printf
        p.pug
        p.readline
        p.regex
        p.ruby
        p.rust
        p.slint
        p.sql
        p.ssh_config
        p.strace
        p.sway
        p.terraform
        p.tmux
        p.toml
        p.typescript
        p.typst
        p.udev
        p.vim
        p.vimdoc
        p.yaml
        p.starlark
      ]))
      # telescope-nvim
      # telescope-manix
      # telescope-ultisnips-nvim
      # telescope-cheat-nvim
      # telescope-undo-nvim
      # telescope-glyph-nvim
      # telescope-fzf-native-nvim
      # telescope-file-browser-nvim
      # telescope-vim-bookmarks-nvim
      teamtype
      typst-conceal-vim
      typst-preview-nvim
      typst-vim
      vim-abolish
      vim-pug
      vim-visual-increment
      yazi-nvim
    ];
    extraLuaConfig = /* lua */ ''
      require("slaxor");
      vim.cmd [[ colorscheme unokai ]];
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.g.mapleader = ","
      -- vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        -- pattern = "*kubeconfig",
        -- command = "setfiletype yaml",
      -- })
       vim.filetype.add({
        pattern = {
          ["%.yaml%.tmpl$"]  = "yaml.gotexttmpl",
          ["%.json%.tmpl$"]  = "json.gotexttmpl",
          [".*/kube/config"] = "yaml",
          [".*kubeconfig"]   = "yaml",
        },
      })
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = { "*" },
        callback = function()
          if vim.bo.binary then return end
          local save_cursor = vim.fn.winsaveview()
          vim.api.nvim_exec2([[keeppatterns %s/\s\+$//e]], { output = false })
          vim.fn.winrestview(save_cursor)
        end,
      })

      local luasnip = require("luasnip")
      -- require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = {
          "${pkgs.vimPlugins.friendly-snippets}",
          "${config.xdg.configHome}/nvim/luasnip",
        }
      })
      require("fidget").setup({})
      -- require("claudecode").setup({})
      -- vim.keymap.set('n', '<leader>cc', ':ClaudeCodeStart<CR>', { desc = 'Start ClaudeCode server' })
      -- vim.keymap.set('n', '<leader>cs', ':ClaudeCodeStop<CR>', { desc = 'Stop ClaudeCode server' })
      -- vim.keymap.set('n', '<leader>ca', ':ClaudeCodeAdd<CR>', { desc = 'Add file to ClaudeCode context' })
      -- vim.keymap.set('v', '<leader>ca', ':ClaudeCodeAdd<CR>', { desc = 'Add selection to ClaudeCode context' })
      vim.api.nvim_set_keymap("i", "<Tab>", [[luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>']], {expr=true, silent=true})
      vim.api.nvim_set_keymap("s", "<Tab>", [[<Cmd>lua require('luasnip').jump(1)<CR>]], {silent=true})
      vim.api.nvim_set_keymap("i", "<S-Tab>", [[<Cmd>lua require('luasnip').jump(-1)<CR>]], {silent=true})
      vim.api.nvim_set_keymap("s", "<S-Tab>", [[<Cmd>lua require('luasnip').jump(-1)<CR>]], {silent=true})

      vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
      -- vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
      -- vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
      -- vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
      -- vim.keymap.set({"i", "s"}, "<C-E>", function()
      --   if ls.choice_active() then
      --     ls.change_choice(1)
      --   end
      -- end, {silent = true})
      vim.api.nvim_create_autocmd("BufEnter", {
        desc = "Meld-like mnemonic bindings using 'm' namespace",
        callback = function()
          if vim.wo.diff then
            local opts = { buffer = true, silent = true }
            -- 'mn' -> skip to next (merge next)
            vim.keymap.set('n', 'mn', ']c', opts)
            -- 'ml' -> use left (merge left)
            vim.keymap.set('n', 'ml', '<Cmd>diffget LOCAL<CR>', opts)
            -- 'mr' -> use right (merge right)
            vim.keymap.set('n', 'mr', '<Cmd>diffget REMOTE<CR>', opts)
            -- 'msl' -> single line left (merge single left)
            vim.keymap.set('n', 'msl', 'V:diffget LOCAL<CR>', opts)
            -- 'msr' -> single line right (merge single right)
            vim.keymap.set('n', 'msr', 'V:diffget REMOTE<CR>', opts)
            -- 'msr' -> single line right (merge single right)
            vim.keymap.set('n', 'mf', ':wqa<CR>', opts)
          end
        end
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.nix",
        callback = function() vim.lsp.buf.format() end,
      })
    '';
  };

  xdg.configFile = {
    # "nvim/init.lua".source = ./nvim/init.lua;
    "nvim/lua/slaxor".source = ./nvim/lua/slaxor;
    "nvim/ftplugin".source = ./nvim/ftplugin;
    "nvim/after".source = ./nvim/after;
    "nvim/luasnip".source = ./nvim/luasnip;
    # "nvim/UltiSnips".source = ./nvim/UltiSnips;
    "nvim/spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
    "nvim/spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
    "nvim/spell/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
    "nvim/spell/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
    "efm-langserver/config.yaml".source = ./efm-langserver/config.yaml;
    "yamllint/config".source = ./yamllint/config;
  };
}
