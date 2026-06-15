{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ctpv
    ueberzugpp
    chafa
    bat
    ouch
    mediainfo
    miller
  ];

  programs.lf = {
    enable = true;

    settings = {
      hidden = true;
      dirfirst = true;
      ratios = "1:3:4";
      ignorecase = true;
      icons = true;
      sixel = true;
      info = "size";
    };

    previewer.source = "${pkgs.ctpv}/bin/ctpv";

    extraConfig = ''
      set cleaner ${pkgs.ctpv}/bin/ctpvclear
      &${pkgs.ctpv}/bin/ctpv -s $id
      &${pkgs.ctpv}/bin/ctpvquit $id
    '';

    commands = {
      chmod = ''
        ''${{
          printf "mode: "
          read mode
          chmod "$mode" $fx
          lf -remote "send $id reload"
        }}
      '';

      diff-hovered = ''
        ''${{
          [ -n "$fs" ] && diff --color=always $fs "$f" | less -R
        }}
      '';

      extract = ''
        ''${{
          ${pkgs.ouch}/bin/ouch decompress $fx
        }}
      '';

      mutt-attach = ''
        ''$neomutt -a $fx
      '';

      subshell = ''
        ''$$SHELL -l
      '';
    };

    keybindings = {
      cm = "chmod";
      "<c-d>" = "diff-hovered";
      "+" = ":set ratios 1:9";
      "=" = ":set ratios 1:3:4";
      "-" = ":set preview!";
      "<c-o>" = "subshell";
      am = "mutt-attach";
      x = "extract";
    };
  };
}
