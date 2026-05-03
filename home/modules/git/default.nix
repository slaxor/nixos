{ pkgs, config, ... }:
let
  git-clonepath = pkgs.writeShellApplication {
    name = "git-clonepath";
    runtimeInputs = [
      pkgs.git
      pkgs.coreutils
    ];
    text = builtins.readFile ./bin/git-clonepath;
  };
in

{
  home.packages = with pkgs; [
    git
    gitui
    git-clonepath
  ];

  programs.git = {
    enable = true;

    includes = [
      { path = "${config.xdg.configHome}/git/config_local"; }
    ];
    settings = {
      user = {
        name = config.me.identity.name;
        email = config.me.identity.email;
        signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      signing = {
        signByDefault = true;
      };
      alias = {
        st = "status";
        di = "diff --ignore-space-change --ignore-cr-at-eol";
        ci = "commit";
        br = "branch";
        co = "checkout";
        sw = "switch";
        swm = "switch master";
        swc = "switch -c";
        df = "diff";
        lg = "log --graph --format='%cd %C(yellow)%h%C(red bold)%d%Creset%C(cyan) [%cn]%Creset %s' --date=short --abbrev=10";
        oneline = "log --pretty=oneline";
        wh = "log -n 40 --pretty=tformat:'%Cblue%h %Creset%cr by %Cred%cn %Cgreen%s%Creset'";
        idid = "log --author='${config.me.identity.name} <${config.me.identity.email}>' --reverse --pretty=tformat:'%Cblue%h %Creset%ai %Cgreen%s%Creset'";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        type = "cat-file -t";
        dump = "cat-file -p";
        pullall = "!f(){ git pull \"$@\" && git submodule update --init --recursive; }; f";
      };
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      pull.rebase = false;
      fetch.recurseSubmodules = true;
      color = {
        ui = "auto";
        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
        };
        status = {
          added = "yellow";
          changed = "green";
          untracked = "cyan";
        };
      };
      core = {
        quotepath = false;
        excludesfile = "gitignore";
        editor = "nvim";
      };
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
      mergetool."nvimdiff" = {
        # This command opens 3 vertical columns: Local, Merged (Result), and Remote
        cmd = "nvim -d -c 'wincmd J' \"$BASE\" \"$LOCAL\" \"$REMOTE\"";
        trustExitCode = true;
      };
      # mergetool."nvimdiff" = {
      # layout = "(LOCAL,BASE,REMOTE)/MERGED";
      # };
      http = {
        sslCAinfo = "/etc/ssl/certs/ca-certificates.crt";
        cookiefile = "${config.home.homeDirectory}/.gitcookies";
      };
      "http \"https://gopkg.in\"" = {
        followRedirects = true;
      };
      credential.helper = "!gopass show git-creds $@";
      clean.requireForce = false;
      init.defaultBranch = "master";
      rerere.enabled = true;
      branch.sort = "-committerdate";
      gpg.format = "ssh";
    };
  };

  # xdg = {
  # enable = true;
  # configFile = {
  # "git/config".source = ./git/config;
  # };
  # };
}
