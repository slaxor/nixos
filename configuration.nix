{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [ ./hosts/taz.nix ];
}
