{ pkgs, ... }:
let
  ft = "${pkgs.framework-tool}/bin/framework_tool";
  charge-limit = pkgs.writeShellApplication {
    name = "charge-limit";
    runtimeInputs = [ pkgs.gnused ];
    text = ''
      get() {
        /run/wrappers/bin/sudo ${ft} --charge-limit | sed -n 's/.*Maximum \([0-9]*\)%.*/\1/p'
      }

      toggle() {
        if [ "$(get)" = 100 ]; then next=80; else next=100; fi
        /run/wrappers/bin/sudo ${ft} --charge-limit "$next"
      }

      case "''${1:-get}" in
        get) get ;;
        toggle) toggle ;;
        *) echo "usage: charge-limit [get|toggle]" >&2; exit 1 ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [ charge-limit ];

  security.sudo.extraRules = [
    {
      users = [ "slash" ];
      commands =
        map
          (args: {
            command = "${ft} ${args}";
            options = [ "NOPASSWD" ];
          })
          [
            "--charge-limit"
            "--charge-limit 80"
            "--charge-limit 100"
          ];
    }
  ];
}
