{ ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # services.pipewire = {
  #   raopOpenFirewall = true;
  #   extraConfig.pipewire."60-raop" = {
  #     "context.modules" = [
  #       {
  #         name = "libpipewire-module-raop-discover";
  #         args = {
  #           "stream.rules" = [
  #             {
  #               matches = [ { "raop.ip" = "~.*"; } ];
  #               actions = {
  #                 "create-stream" = { };
  #               };
  #             }
  #           ];
  #         };
  #       }
  #     ];
  #   };
  # };
}
