{ ... }:
{
  # imports = [ inputs.fterm.homeManagerModules.default ];
  programs.fterm = {
    enable = true;
    init = ''
      s" /dev/ttyUSB0" port  115200 baud
      3000 timeout                    \ ms to wait for the prompt after each line
      s" lib" path                    \ extra #include/#require search dir
      s" .fterm_history" history  \ per-project history; default $XDG_STATE_HOME/fterm/history
      \ 10 eol                        \ line end: 13 = CR (default), 10 = LF, 0 = CRLF
      \ s" ok." prompt                \ success marker at the end of a reply line
      \ s" Unknown" error             \ add an error pattern; no-errors clears the defaults

      : flash   s" dcf77.fs" upload s" pins.fs" upload ;
      : probe   s" decode" run  s" CET" 70000 expect if ." DCF77 ok" else ." no time" then cr ;
      : reboot  s" reset" run  2000 delay  s" dcf77.fs" upload  s" pins.fs" upload ;

      ' flash  bind F5
      ' reboot bind F6
      ' probe  bind p                 \ ctrl-t p

      \ runs after every (re)connect
      : on-connect  s" autoexec.fs" upload? ;
      \ 2 timestamps
      : reboot  s" reset" run  2000 delay ;
      ' reboot bind F6
    '';
  };
}
