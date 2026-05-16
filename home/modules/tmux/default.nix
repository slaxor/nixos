{ pkgs, ... }:
# let
# fdCmd = "${pkgs.fd}/bin/fd --search-path git.int.m11s.de/slaxor --search-path git.int.m11s.de/microprojects --search-path codeberg.org/slaxor --type d --changed-within 52w --follow --max-depth 1";
# in
{
  home.packages = with pkgs; [
    tmate
    sesh
    fzf
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.bash}/bin/bash";
    shortcut = "`";
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    escapeTime = 50;
    secureSocket = true;
    mouse = true;
    clock24 = true;
    historyLimit = 50000;

    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      copycat
      tmux-fzf
      pain-control
      resurrect
      sensible
      tilish
      yank
      tmux-floax
    ];

    extraConfig = ''
      set -g @resurrect-strategy-vim 'session'
      set -g @resurrect-strategy-nvim 'session'
      set -g prefix `
      set -s escape-time 50
      set -ga terminal-overrides ",tmux-256color:Tc"
      set -g status-right '#[fg=black,bg=color15] #{cpu_percentage}  %H:%M '
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"
      set-option -g renumber-windows on
      if-shell '[ "$USER" = "slash" ]' \
         'set-option -g status-bg "#285577" ;\
           set-option -g status-fg "#ffffff"'
      if-shell '[ "$USER" = "root" ]' \
        'set-option -g status-fg colour8 ;\
           set-option -g status-bg colour52'
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind Left select-pane -L
      bind Down select-pane -D
      bind Up select-pane -U
      bind Right select-pane -R
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
      bind ` send-key `
      bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
      bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
      set -g detach-on-destroy off  # don't exit from tmux when closing a session
      bind -N "last-session (via sesh) " L run-shell "sesh last"
      bind -N "switch to root session (via sesh) " 9 run-shell "sesh connect --root \'$(pwd)\'"
      bind-key "s" run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""

      set -g @floax-bind '<space>'
      set -g @floax-bind-menu 'P'
      set -g @floax-width '80%'
      set -g @floax-height '80%'
      set -g @floax-border-color 'magenta'
      set -g @floax-text-color 'blue'
      set -g @floax-change-path 'true'
      set -g @floax-session-name 'some-other-session-name'
      set -g @floax-title 'floax'
    '';
  };

  home.shellAliases = {
    tks = "tmux kill-server";
    tnw = "tmux new-window";
    tpalette = "for i in {0..255}; do printf \"\\x1b[38;5;\${i}mcolor\${i} - ██████████\n\"; done";
  };

  programs = {
    sesh = {
      enable = true;
      settings = {
        blacklist = [ "scratch" ];
        dir_length = 2;
        sort_order = [
          "config"
          "tmux"
          # "zoxide"
        ];
        default_session = {
          # preview_command = "ls -ogAht --group-directories-first {}";
          preview_command =
            "eza -lah --group-directories-first "
            + "--sort=modified --long --no-permissions --no-user "
            + "--color=always --git -b {}";
        };
        session = [
          {
            name = "Downloads 📥";
            path = "~/Downloads";
            startup_command = "yazi";
          }
          {
            name = "nixos";
            path = "~/git/codeberg.org/slaxor/nixos";
            preview_command = "bat --no-paging -n --line-range 2:27 flake.nix";
            windows = [
              "edit"
              "switch"
              "sh"
            ];
          }
        ];
      };
    };

    tmate = {
      enable = true;
      dsaFingerprint = "SHA256:/di5H5EOUy2Bt+oid1NadGnYf6mNMrz+0QVIm4LhCjo";
      # host = "tmate.m11s.de";
      # port = 2222;
      extraConfig = ''
        set -g @resurrect-strategy-vim 'session'
        set -g @resurrect-strategy-nvim 'session'
        set -g prefix `
        set -s escape-time 50
        set -ga terminal-overrides ",tmux-256color:Tc"
        set -g status-right '#[fg=black,bg=color15] #{cpu_percentage}  %H:%M '
        # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        set-environment -g COLORTERM "truecolor"
        set-option -g renumber-windows on
        if-shell '[ "$USER" = "slash" ]' \
           'set-option -g status-bg "#285577" ;\
             set-option -g status-fg "#ffffff"'
        if-shell '[ "$USER" = "root" ]' \
          'set-option -g status-fg colour8 ;\
             set-option -g status-bg colour52'
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
        bind Left select-pane -L
        bind Down select-pane -D
        bind Up select-pane -U
        bind Right select-pane -R
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
        bind ` send-key `
        bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
        bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
        set -g detach-on-destroy off  # don't exit from tmux when closing a session
        bind -N "last-session (via sesh) " L run-shell "sesh last"
        bind -N "switch to root session (via sesh) " 9 run-shell "sesh connect --root \'$(pwd)\'"
        bind-key "s" run-shell "sesh connect \"$(
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\""

        set -g @floax-bind '<space>'
        set -g @floax-bind-menu 'P'
        set -g @floax-width '80%'
        set -g @floax-height '80%'
        set -g @floax-border-color 'magenta'
        set -g @floax-text-color 'blue'
        set -g @floax-change-path 'true'
        set -g @floax-session-name 'some-other-session-name'
        set -g @floax-title 'floax'
      '';
    };
    fzf.tmux.enableShellIntegration = true;
  };
}
