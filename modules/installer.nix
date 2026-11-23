{ lib, pkgs, ... }:
{
  system.stateVersion = lib.mkDefault lib.trivial.release;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.root.openssh.authorizedKeys.keys = import ../users/slash-keys.nix;

  environment.systemPackages = with pkgs; [
    disko
    git
    tmux
  ];
}
