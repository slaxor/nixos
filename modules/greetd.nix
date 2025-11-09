{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    greetd.greetd
  ];

  # services.getty.autologinUser = "slash";

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "slash";
      };
      default_session = initial_session;
    };
  };
}

